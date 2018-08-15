SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Dennis Mitchell
-- Create date: 2018-08-15
-- Description:	Purges all data in 
--              _maintenance.TestJson and its
--              history table
-- =============================================
CREATE PROCEDURE [_maintenance].[TruncateTestJson] 
AS
BEGIN

	alter table _maintenance.TestJson set (system_versioning = off);
	truncate table _maintenance.TestJson;
	truncate table _maintenance.TestJsonHistory;
	alter table _maintenance.TestJson set (system_versioning=on (history_table = _maintenance.TestJsonHistory));

END
