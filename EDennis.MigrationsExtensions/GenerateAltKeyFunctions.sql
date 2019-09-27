/****** Object:  StoredProcedure [_].[Temporal_AddHistoryTables]    Script Date: 2/27/2018 3:01:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================
-- Author:      Dennis Mitchell
-- Create date: 2018-02-24
-- Description: Adds Row-level security based upon HOST_NAME()
-- ===========================================================================
CREATE PROCEDURE [_].[GenerateAltKeyFunctions]
AS
BEGIN
 
		declare @TableSchema varchar(55)		
		declare @TableName varchar(200)		
		declare @sql varchar(max)
  

		--
		-- ITERATE OVER ALL TABLES THAT ARE REFERENCED BY A FOREIGN KEY
		--
      
		declare c_table cursor for
			SELECT DISTINCT 
				ReferencedSchema.name AS ReferencedSchema,
				ReferencedTable.name AS ReferencedTable
				FROM sys.foreign_key_columns ForeignKeyColumns
				INNER JOIN sys.objects SysObjects
					ON SysObjects.object_id = ForeignKeyColumns.constraint_object_id
				INNER JOIN sys.tables ReferencedTable
					ON ReferencedTable.object_id = ForeignKeyColumns.referenced_object_id
				INNER JOIN sys.schemas ReferencedSchema
					ON ReferencedTable.schema_id = ReferencedSchema.schema_id

		open c_table
		fetch next from c_table into @TableSchema, @TableName
              while @@fetch_status = 0
              begin
                     if @TableName is not null
                     begin
	                     print @TableSchema + ',' + @TableName

                     --
                     --  CREATE FUNCTION
                     --

declare @sql varchar(max) = 'SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===========================================================================
-- Author:      Dennis Mitchell
-- Create date: 2019-02-24
-- Description: Returns the GUID alternative key value for ' + @TableSchema + '.' + @TableName + '
--              at a particular rownumber ordered by Id
-- ===========================================================================
create function _.[' + case when @TableSchema = 'dbo' then '' else @TableSchema + '_' end +  @TableName + 'Id](@RowNumber int)
returns uniqueidentifier
as begin
	declare @altkey uniqueidentifier;
	select @altkey = ' + @TableName + 'Id from (
		select ' + @TableName + 'Id, row_number() over (order by Id) RowNumber 
			from ' + @TableSchema + '.' + @TableName + '
		) a where RowNumber = @RowNumber 
	return @altkey
end
go'
							
						exec(@sql)

                     end
                     fetch next from c_table into @TableSchema, @TableName
              end
              close c_table
              deallocate c_table

 
END