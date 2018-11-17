SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Dennis Mitchell
-- Create date: 2018-11-17
-- Description:	Builds a basic table definition
--              with primary key constraint, but
--              omits other constraints and 
--              identity specification
-- =============================================
CREATE FUNCTION _maintenance.Temporal_GetBaseHistoryTableDefinition 
(
	@TemporalSchemaName varchar(255) = 'dbo',
	@TemporalTableName varchar(255),
	@HistorySchemaName varchar(255) = 'dbo_history',
	@HistoryTableName varchar(255)
)
RETURNS varchar(max)
AS
BEGIN
 
	declare @ColumnClauses varchar(max) = '' 
	declare @ColumnName varchar(255)
	declare @DataType varchar(255)
	declare @CharacterMaximumLength int
	declare @NumericPrecision tinyint
	declare @NumericScale int
	declare @IsNullable varchar(10)
 
	declare crsr cursor for
		select
			c.column_name ColumnName,
			c.data_type DataType,
			c.character_maximum_length CharacterMaximumLength,
			c.numeric_precision NumericPrecision,
			c.numeric_scale NumericScale,
			c.is_nullable IsNullable
		FROM information_schema.columns c
		left outer join information_schema.table_constraints p
			on p.table_schema = @TemporalSchemaName
				and p.table_name = @TemporalTableName
				and p.constraint_type = 'PRIMARY KEY'
		left outer join information_schema.key_column_usage kc
			on kc.table_schema = @TemporalSchemaName
				and kc.table_name = @TemporalTableName
				and kc.column_name = c.column_name
				and kc.constraint_name = p.constraint_name
		where c.table_schema = @TemporalSchemaName 
			and c.table_name = @TemporalTableName
		order by case when kc.column_name is null then 100000 + c.ordinal_position else c.ordinal_position end

	open crsr
	fetch next from crsr into @ColumnName,@DataType,@CharacterMaximumLength,
			@NumericPrecision,@NumericScale,@IsNullable

	while @@FETCH_STATUS = 0
	begin
		if @ColumnName is not null
			begin
				set @ColumnClauses = @ColumnClauses + '[' + @ColumnName + '] '
					+  @DataType
					+  case
							when @DataType in ('char','varchar','nchar','nvarchar','binary','varbinary')
								then '(' + case when @CharacterMaximumLength = -1 then 'max' else convert(varchar(10), @CharacterMaximumLength) end + ')'
							when @DataType in ('numeric','decimal')
								then '(' + convert(varchar(10), @NumericPrecision) + ',' + convert(varchar(10), @NumericScale) + ')'
							else ''
							end
					+ case when @IsNullable = 'NO' then ' NOT' else '' end + ' NULL' + ', '
			end
		fetch next from crsr into @ColumnName,@DataType,@CharacterMaximumLength,
				@NumericPrecision,@NumericScale,@IsNullable
	end

	close crsr
	deallocate crsr

	set @ColumnClauses = substring(@ColumnClauses,1,len(@ColumnClauses)-1)

	declare @Statement nvarchar(max)
	set @Statement =  'CREATE TABLE [' + @HistorySchemaName +  '].[' + @HistoryTableName +  '] ( '
		+ @ColumnClauses + ');'

	return @Statement;
END
GO