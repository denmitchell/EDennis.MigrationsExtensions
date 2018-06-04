/****** Object:  StoredProcedure [_maintenance].[SaveTestJson]    Script Date: 6/4/2018 12:15:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Dennis Mitchell
-- Create date: 2018-05-24
-- Description:	Merges a record into 
--              _maintenance.TestJson
-- =============================================
CREATE PROCEDURE [_maintenance].[SaveTestJson] 
	@Project varchar(100), @Class varchar(100), @Method varchar(100), 
	@FileName varchar(100), @Json varchar(max)
AS
BEGIN

	merge _maintenance.TestJson as target
	using (select @Project Project, @Class Class, @Method Method, @FileName FileName, @Json Json) as source
		on target.Project = source.Project and target.Class = source.Class 
			and target.Method = source.Method and target.FileName = source.FileName

	when matched and target.Json <> source.Json
		then update set target.json = source.Json
	when not matched by target 
		then insert (Project,Class,Method,FileName,Json)
			values(source.Project, source.Class, source.Method, source.FileName, source.Json);


END
