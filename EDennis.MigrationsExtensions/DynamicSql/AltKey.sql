SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===========================================================================
-- Author:      Dennis Mitchell
-- Create date: 2019-02-24
-- Description: Returns the GUID alternative key value for @TableName
--              at a particular rownumber ordered by Id
-- ===========================================================================
create function _.[@TableNameId](@RowNumber int)
returns uniqueidentifier
as begin
	declare @altkey uniqueidentifier;
	select @altkey = @TableNameId from (
		select @TableNameId, row_number() over (order by Id) RowNumber 
			from @TableName
		) a where RowNumber = @RowNumber 
	return @altkey
end
go