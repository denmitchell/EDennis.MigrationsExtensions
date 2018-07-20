USE [Form255]
GO
/****** Object:  StoredProcedure [_maintenance].[SaveTestJson]    Script Date: 7/20/2018 1:38:24 PM ******/
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
-- =============================================
CREATE PROCEDURE [_maintenance].[SaveTestJson] 
	@Project varchar(100), @Class varchar(100), @Method varchar(100), 
	@FileName varchar(100), @Json varchar(max)
AS
BEGIN

	delete from _maintenance.TestJson
		where Project = @Project and Class = @Class and Method = @Method and FileName = @FileName

	insert into _maintenance.TestJson (Project,Class,Method,FileName,Json)
				values(@Project, @Class, @Method, @FileName, @Json);

	/*

	merge _maintenance.TestJson as target
	using (select @Project Project, @Class Class, @Method Method, @FileName FileName, @Json Json) as source
		on target.Project = source.Project and target.Class = source.Class 
			and target.Method = source.Method and target.FileName = source.FileName

	when matched and target.Json <> source.Json
		then update set target.json = source.Json
	when not matched by target 
		then insert (Project,Class,Method,FileName,Json)
			values(source.Project, source.Class, source.Method, source.FileName, source.Json);

	*/
END