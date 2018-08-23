/****** Object:  StoredProcedure [_maintenance].[SaveTestJson]    Script Date: 8/6/2018 4:51:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Dennis Mitchell
-- Create date: 2018-05-24
-- Description:	Merges a record into 
--              _maintenance.TestJson
-- Modified on: 2018-07-20:
--				Replaced Merge command with
--				Delete and Insert because the
--				merge command seemed to be
--				working inconsistently -- 
--				sometimes no JSON was inserted
--				(for some users and not others).
--				This was a mystery that we 
--				couldn't totally solve except
--				by updating this procedure.
--
-- Modified on: 2018-08-06:
--				Conforms to new TestJson model
-- =============================================
CREATE PROCEDURE [_maintenance].[SaveTestJson] 
	@ProjectName varchar(100), @ClassName varchar(100), @MethodName varchar(100), 
	@TestScenario varchar(100), @TestCase varchar(100), @TestFile varchar(100), 
	@Json nvarchar(max)
AS
BEGIN

	delete from _maintenance.TestJson
		where ProjectName = @ProjectName and ClassName = @ClassName and MethodName = @MethodName 
			and TestScenario = @TestScenario and TestCase = @TestCase and TestFile = @TestFile 

	insert into _maintenance.TestJson (ProjectName, ClassName, MethodName, 
				TestScenario, TestCase, TestFile, [Json])
				values(@ProjectName, @ClassName, @MethodName, 
						@TestScenario, @TestCase, @TestFile, @Json);


END
