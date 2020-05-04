/****** Object:  StoredProcedure [_].[Temporal_UpdateExtendedProperties]    Script Date: 2/25/2018 4:34:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================
-- Author:      Dennis Mitchell
-- Create date: 2018-02-24
-- Description: Updates Extended Properties for all temporal tables and columns 
-- ===========================================================================
CREATE PROCEDURE [_].[Temporal_UpdateExtendedProperties]
AS
BEGIN

declare @HistoryTableSchema varchar(255)
declare @TemporalTableSchema varchar(255)
declare @TemporalTableName varchar(255), @HistoryTableName varchar(255)
declare @SysStartColumnName varchar(255), @SysEndColumnName varchar(255) 
declare @cnt int = 0;
declare @sql varchar(max)
declare @val varchar(255), @name varchar(255)

--
-- BUILD A TABLE OF EXISTING SYSTEM TIME COMPONENTS (RELEVANT SCHEMAS, TABLES, AND COLUMNS)
--
    declare @tt table (
            TemporalTableSchema varchar(30),
            TemporalTableName varchar(255),
            HistoryTableSchema varchar(30),
            HistoryTableName varchar(255),
            SysStartColumnName varchar(255),
            SysEndColumnName varchar(255)
    );
    insert into @tt exec _.Temporal_GetMetadataFromInfoSchema


--
-- DECLARE CURSOR FOR TEMPORAL METADATA
--

	declare c_tt cursor for
		select TemporalTableSchema, TemporalTableName, HistoryTableSchema, 
				HistoryTableName, SysStartColumnName, SysEndColumnName 
				from @tt
					
--
-- CURSOR FOR EACH TEMPORAL TABLE
--
	open c_tt
	fetch next from c_tt into @TemporalTableSchema, @TemporalTableName, @HistoryTableSchema, 
				@HistoryTableName, @SysStartColumnName, @SysEndColumnName
	while @@fetch_status = 0
	begin
		if @TemporalTableSchema is not null
		begin

		--
		--  DROP EXTENDED PROPERTIES FOR SYSTEM_START_TIME AND SYSTEM_END_TIME COLUMNS
		--
			if exists (
				select 0
					from sys.extended_properties as ep
					inner join sys.columns AS c ON ep.major_id = c.object_id AND ep.minor_id = c.column_id
					inner join sys.tables as t on t.object_id = c.object_id 
					inner join sys.schemas as s on s.schema_id = t.schema_id
					where s.name = @TemporalTableSchema 
						and t.name=@TemporalTableName 
						and c.name = @SysStartColumnName 
						and ep.name = 'SystemTimeComponent'
						and ep.class_desc = N'OBJECT_OR_COLUMN'
			)				
			begin
				execute sp_dropextendedproperty
					@name='SystemTimeComponent',
					@level0type = N'Schema',
					@level0name = @TemporalTableSchema,
					@level1type = N'Table',
					@level1name = @TemporalTableName,
					@level2type = N'Column',
					@level2name = @SysStartColumnName
			end

			if exists (
				select 0
					from sys.extended_properties as ep
					inner join sys.columns AS c ON ep.major_id = c.object_id AND ep.minor_id = c.column_id
					inner join sys.tables as t on t.object_id = c.object_id 
					inner join sys.schemas as s on s.schema_id = t.schema_id
					where s.name = @TemporalTableSchema 
						and t.name=@TemporalTableName 
						and c.name = @SysEndColumnName 
						and ep.name = 'SystemTimeComponent'
						and ep.class_desc = N'OBJECT_OR_COLUMN'
			)				
			begin
				execute sp_dropextendedproperty
					@name='SystemTimeComponent',
					@level0type = N'Schema',
					@level0name = @TemporalTableSchema,
					@level1type = N'Table',
					@level1name = @TemporalTableName,
					@level2type = N'Column',
					@level2name = @SysEndColumnName
			end


		--
		-- ADD EXTENDED PROPERTY FOR SYSTEM_START_TIME COLUMN
		--

			execute sp_addextendedproperty 
				@name='SystemTimeComponent', 
				@value='SystemStartTimeColumn',
				@level0type = N'Schema',
				@level0name = @TemporalTableSchema,
				@level1type = N'Table',
				@level1name = @TemporalTableName,
				@level2type = N'Column',
				@level2name = @SysStartColumnName

		--
		--  ADD EXTENDED PROPERTY FOR SYSTEM_END_TIME COLUMN
		--

			execute sp_addextendedproperty 
				@name='SystemTimeComponent', 
				@value='SystemEndTimeColumn',
				@level0type = N'Schema',
				@level0name = @TemporalTableSchema,
				@level1type = N'Table',
				@level1name = @TemporalTableName,
				@level2type = N'Column',
				@level2name = @SysEndColumnName 


		--
		--  ADD EXTENDED PROPERTY FOR HISTORY TABLE
		--

			if exists (
				select 0
					from sys.extended_properties as ep
					inner join sys.tables as t on t.object_id = ep.major_id 
					inner join sys.schemas as s on s.schema_id = t.schema_id
					where s.name = @HistoryTableSchema 
						and t.name = @HistoryTableName
						and ep.name = 'SystemTimeComponent'
						and ep.minor_id = 0 
			)				
			begin
				execute sp_dropextendedproperty 
					@name='SystemTimeComponent', 
					@level0type = N'Schema',
					@level0name = @HistoryTableSchema,
					@level1type = N'Table',
					@level1name = @HistoryTableName
			end


			set @val = 'HistoryTableFor:' + @TemporalTableSchema + '.' + @TemporalTableName

			execute sp_addextendedproperty 
				@name='SystemTimeComponent', 
				@value=@val,
				@level0type = N'Schema',
				@level0name = @HistoryTableSchema,
				@level1type = N'Table',
				@level1name = @HistoryTableName


		--
		--  ADD EXTENDED PROPERTY FOR TEMPORAL TABLE
		--
			if exists (				
				select 0
					from sys.extended_properties as ep
					inner join sys.tables as t on ep.major_id = t.object_id 
					inner join sys.schemas as s on s.schema_id = t.schema_id
					where s.name = @TemporalTableSchema 
						and t.name=@TemporalTableName
						and ep.name = 'SystemTimeComponent'
						and ep.minor_id = 0 
			)
			begin
				execute sp_dropextendedproperty 
					@name='SystemTimeComponent', 
					@level0type = N'Schema',
					@level0name = @TemporalTableSchema,
					@level1type = N'Table',
					@level1name = @TemporalTableName
			end
				
			execute sp_addextendedproperty 
				@name='SystemTimeComponent', 
				@value='TemporalTable',
				@level0type = N'Schema',
				@level0name = @TemporalTableSchema,
				@level1type = N'Table',
				@level1name = @TemporalTableName
				

		end
		fetch next from c_tt into @TemporalTableSchema, @TemporalTableName, @HistoryTableSchema, 
				@HistoryTableName, @SysStartColumnName, @SysEndColumnName
	end

	close c_tt
	deallocate c_tt

END
GO


