declare @TableName varchar(500) = '@TableName';
declare @TableSchema varchar(500) = '@TableSchema';
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
PRINT @sql