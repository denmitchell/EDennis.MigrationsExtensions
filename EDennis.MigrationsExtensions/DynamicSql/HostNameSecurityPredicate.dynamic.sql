declare @SchemaName varchar(500) = '@SchemaName';
declare @sql varchar(max) = 'SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================
-- Author:		Dennis Mitchell
-- Create date: 2019-09-26
-- Description:	Create a filter predicate for HOST_NAME()
--              If the login user is sa, allow all operations
-- ==========================================================

CREATE OR ALTER FUNCTION [' + @SchemaName + '].HostNameSecurityPredicate(@HostName AS sysname)  
	RETURNS TABLE  
WITH SCHEMABINDING  
AS  
	RETURN SELECT 1 AS fn_HostNameSecurityPredicate
		WHERE @HostName = HOST_NAME()
		OR ORIGINAL_LOGIN() = ''sa'';

GO

'
PRINT @sql