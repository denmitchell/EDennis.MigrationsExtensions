SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Dennis Mitchell
-- Create date: 2018-05-24
-- Description:	Creates a TestJson table
-- =============================================
CREATE TABLE _maintenance.TestJson(
       ProjectName varchar(100),
       ClassName varchar(100),
       MethodName varchar(100),
       TestScenario varchar(100),
       TestCase varchar(100),
       TestFile varchar(100),
       Json nvarchar(max),
	   SysStart datetime2 GENERATED ALWAYS AS ROW START NOT NULL default (getdate()),
	   SysEnd datetime2 GENERATED ALWAYS AS ROW END NOT NULL default (CONVERT([datetime2],'9999-12-31 23:59:59.9999999')),
       constraint pk_maintenanceTestJson 
              primary key (ProjectName, ClassName, MethodName,
			  TestScenario, TestCase, TestFile),
	   period for system_time (SysStart, SysEnd)
) with (system_versioning = on (history_table = _maintenance.TestJsonHistory));

