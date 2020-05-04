SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===========================================================================
-- Author:      Dennis Mitchell
-- Create date: 2019-02-24
-- Description: Returns the datetime2 value that is immediately before @dt
-- ===========================================================================
create or alter function _.RightBefore(@dt datetime2)
returns datetime2
as begin
	return dateadd(nanosecond,-100,@dt)
end
go