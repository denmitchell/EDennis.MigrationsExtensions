SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Dennis Mitchell
-- Create date: 2018-08-15
-- Description:	Purges all data in 
--              _.TestJson and its
--              history table
-- =============================================
CREATE PROCEDURE [_].[TruncateTestJson] 
AS
BEGIN

	alter table _.TestJson set (system_versioning = off);
	truncate table _.TestJson;
	truncate table _.TestJsonHistory;
	alter table _.TestJson set (system_versioning=on (history_table = _.TestJsonHistory));

END
