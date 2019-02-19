/****** Object:  StoredProcedure [_maintenance].[GetTestJson]    Script Date: 8/6/2018 4:51:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Dennis Mitchell
-- Create date: 2019-02-19
-- Description:	Gets records from  
--              _maintenance.TestJson
-- =============================================
CREATE PROCEDURE [_maintenance].[GetTestJson] 
	@ProjectName varchar(100), 
	@ClassName varchar(100) = null, 
	@MethodName varchar(100) = null, 
	@TestScenario varchar(100) = null, 
	@TestCase varchar(100) = null,
	@TestFile varchar(100) = null
AS
BEGIN

if @ClassName is null
	select * from _maintenance.TestJson
		where ProjectName = @ProjectName 

else if @MethodName is null
	select * from _maintenance.TestJson
		where ProjectName = @ProjectName 
			and ClassName = @ClassName 

else if @TestScenario is null
	select * from _maintenance.TestJson
		where ProjectName = @ProjectName 
			and ClassName = @ClassName 
			and MethodName = @MethodName 

else if @TestCase is null
	select * from _maintenance.TestJson
		where ProjectName = @ProjectName 
			and ClassName = @ClassName 
			and MethodName = @MethodName 
			and TestScenario = @TestScenario 

else if @TestFile is null
	select * from _maintenance.TestJson
		where ProjectName = @ProjectName 
			and ClassName = @ClassName 
			and MethodName = @MethodName 
			and TestScenario = @TestScenario 
			and TestCase = @TestCase

else
	select * from _maintenance.TestJson
		where ProjectName = @ProjectName 
			and ClassName = @ClassName 
			and MethodName = @MethodName 
			and TestScenario = @TestScenario 
			and TestCase = @TestCase
			and TestFile = @TestFile

END
