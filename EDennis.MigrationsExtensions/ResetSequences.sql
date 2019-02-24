
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===========================================================================
-- Author:      Dennis Mitchell
-- Create date: 2018-02-24
-- Description: Resets all sequence values based upon max value of column that
--              uses the sequence.  This procedure support multiple schemas
--              and the same or different sequences used by different columns.
--              Note that the sequence will only be reset when one or more
--              columns specify the sequence as a default.
-- ===========================================================================
CREATE PROCEDURE _.ResetSequences
AS
BEGIN

	declare @SequenceSchema varchar(255), @TableSchema varchar(255)
	declare @SequenceName varchar(255), @TableName nvarchar(255), @ColumnName nvarchar(255)
	declare @NextValueSql nvarchar(max), @SqlParamDef nvarchar(max), @NextValue int

	set @SqlParamDef = N'@NextValue int OUTPUT'

	declare @seqMax table(
		SequenceSchema varchar(255),
		SequenceName varchar(255),
		MaxValue int
	);

	declare @ResetSql nvarchar(max)

--
-- Get all sequence values used as defaults for columns, and use dynamic SQL to
-- calculate the maximum value of columns using that sequence as a default
--
	declare c_seqtab cursor for
	select 
		s.sequence_schema SequenceSchema, s.sequence_name SequenceName, 
		c.table_schema TableSchema, c.table_name TableName, c.column_name ColumnName,
		'select @NextValue = max([' + c.column_name + ']) + 1 from [' + c.table_schema + '].[' + c.table_name + ']' NextValueSql
		from INFORMATION_SCHEMA.COLUMNS c
		inner join INFORMATION_SCHEMA.SEQUENCES s
			on rtrim(replace(replace(replace(replace(replace(c.COLUMN_DEFAULT,'[',''),']',''),')',''),'(',''),'dbo',''))
				LIKE '%' + 
				case when s.sequence_schema <> 'dbo' then s.sequence_schema + '.' else '' end +  s.SEQUENCE_NAME 
	open c_seqtab
	fetch next from c_seqtab into @SequenceSchema, @SequenceName, @TableSchema, @TableName, @ColumnName, @NextValueSql
	while @@FETCH_STATUS = 0
	begin
		if @SequenceSchema is not null
		begin

			exec sp_executesql	@NextValueSql, 
								@SqlParamDef,
								@NextValue = @NextValue OUTPUT;
			insert into @seqMax (SequenceSchema, SequenceName, MaxValue)
				values (@SequenceSchema, @SequenceName, ISNULL(@NextValue,1))
		end
		fetch next from c_seqtab into @SequenceSchema, @SequenceName, @TableSchema, @TableName, @ColumnName, @NextValueSql	
	end
	close c_seqtab
	deallocate c_seqtab

--
-- Because sequences may be used by more than one table, get the maximum value across all usages,
-- and use that value to reset the sequence
--
	declare @MaxValue int

	declare c_seqmax cursor for
		select SequenceSchema, SequenceName, max(MaxValue) MaxValue
		from @seqMax
		group by SequenceSchema, SequenceName

	open c_seqmax
	fetch next from c_seqmax into @SequenceSchema, @SequenceName, @MaxValue
	while @@fetch_status = 0
	begin
		if @SequenceSchema is not null
		begin
			set @ResetSql = 'alter sequence [' + @SequenceSchema + '].[' + @SequenceName + '] restart with ' + convert(varchar,ISNULL(@MaxValue,1))	
			exec sp_executesql @ResetSql;			
		end
		fetch next from c_seqmax into @SequenceSchema, @SequenceName, @MaxValue
	end
	close c_seqmax
	deallocate c_seqmax


END