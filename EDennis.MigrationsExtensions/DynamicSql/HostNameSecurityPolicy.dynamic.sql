declare @SecuritySchema varchar(500) = '@SecuritySchema';
declare @SecurityPolicyName varchar(500) = '@SecurityPolicyName';
declare @SchemaName varchar(500) = '@SchemaName';
declare @TableName varchar(500) = '@TableName';
declare @FilterColumnName varchar(500) = '@FilterColumnName';
declare @sql varchar(max) = '-- ==========================================================
-- Author:		Dennis Mitchell
-- Create date: 2019-09-26
-- Description:	Create security policy for a given table,
--              applying HostNameSecurityPredicate
-- ==========================================================
CREATE SECURITY POLICY [' + @SecuritySchema + '].[' + @SecurityPolicyName + ']  
	ADD FILTER PREDICATE [' + @SecuritySchema + '].[HostNameSecurityPredicate](' + @FilterColumnName + ')
		ON [' + @SchemaName + '].[' + @TableName + '],  
	ADD BLOCK PREDICATE [' + @SecuritySchema + '].[HostNameSecurityPredicate](' + @FilterColumnName + ')
        ON [' + @SchemaName + '].[' + @TableName + '] AFTER INSERT
	WITH (STATE = ON);
'
PRINT @sql