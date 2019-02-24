SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===========================================================================
-- Author:      Dennis Mitchell
-- Create date: 2019-02-24
-- Description: Returns the maximum value for datetime2
-- ===========================================================================
create function _.MaxDateTime2()
returns datetime2
as begin
	return convert(datetime2,'9999-12-31T23:59:59.9999999')
end
go