/****** Object:  StoredProcedure [_].[GetTestJson]    Script Date: 8/6/2018 4:51:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===========================================================
-- Author:		Dennis Mitchell
-- Create date: 2019-02-19
-- Description:	Gets EF Core mappings (table/class, 
--              column/property) stored in extended properties
--              See EDennis.MigrationsExtensions
--                 SaveMappingsOperation
-- ===========================================================
CREATE OR ALTER PROCEDURE [_].[GetMappings] 
AS
BEGIN
declare @PREFIX varchar(30) = 'efcore:'
select
		f.SchemaName, 
		f.TableName, 
		f.ColumnName, 
		replace(f.Name,@PREFIX,'') NamespaceName,
		substring(f.value,1,charindex('.',f.value)-1) ClassName, 
		substring(f.value,charindex('.',f.value)+1, len(f.value)) PropertyName 
	from (
		select
				c.table_schema SchemaName, 
				c.table_name TableName, 
				c.column_name ColumnName, 
				convert(varchar(255),f.Name) Name,
				convert(varchar(255),f.Value) Value
		from INFORMATION_SCHEMA.columns c
		cross apply ::fn_listextendedproperty(
				default,
				'schema', c.table_schema,
				'table',c.table_name,
				'column',c.column_name) f
			where f.Name is not null 
				and f.Value is not null
				and convert(varchar(255),f.Name) like @PREFIX + '%'
				and convert(varchar(255),f.value) like '%.%'
		) f
END
