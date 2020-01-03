SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================
-- Author:      Dennis Mitchell
-- Create date: 2018-11-17
-- Description: Resets all identity values based upon max value of the 
--              underlying columns.
-- ===========================================================================
CREATE OR ALTER PROCEDURE [_].[ResetIdentities]
AS
BEGIN

declare @SchemaName varchar(255)
declare @TableName varchar(255)
declare @ColumnName varchar(255)
declare @sql nvarchar(255)
declare @max bigint
declare @adjust bit

declare crsr cursor for
	select s.name SchemaName, t.name TableName, i.name ColumnName
		from sys.schemas s
		inner join sys.tables t
			on s.schema_id = t.schema_id
		inner join sys.identity_columns i
			on i.object_id = t.object_id
open crsr
fetch next from crsr 
	into @SchemaName, @TableName, @ColumnName
while @@fetch_status = 0
	begin
		if @SchemaName is not null 
			begin
				set @sql = N'select @max = max(' + @ColumnName + ') from [' + @SchemaName + '].[' + @TableName + '];'
				exec sp_executesql @sql,
					N'@max bigint OUTPUT',
					@max OUTPUT;

				set @sql = N'select @adjust = case when last_value is not null then 1 else 0 end from sys.identity_columns WHERE object_id = object_id(' + char(39) + '[' + @SchemaName + '].[' + @TableName + ']' + char(39) + ') ;'
				exec sp_executesql @sql,
					N'@adjust bit OUTPUT',
					@adjust OUTPUT;

				set @sql = 	'dbcc checkident (' + char(39) + @SchemaName + '.' + @TableName + char(39) + ', reseed, ' + convert(varchar(20), isnull(@max,1) - isnull(@adjust,0)) + ')'
				exec (@sql)
			end
		fetch next from crsr 
			into @SchemaName, @TableName, @ColumnName
	end
close crsr
deallocate crsr

END
GO