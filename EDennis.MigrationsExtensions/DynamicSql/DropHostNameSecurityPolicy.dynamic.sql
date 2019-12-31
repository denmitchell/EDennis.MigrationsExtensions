declare @SecuritySchema varchar(500) = '@SecuritySchema';
declare @SecurityPolicyName varchar(500) = '@SecurityPolicyName';
declare @sql varchar(max) = 'IF EXISTS (SELECT 0 FROM sys.security_predicates sp WHERE OBJECT_ID(''[' + @SecuritySchema + '].[' + @SecurityPolicyName + ']'') = sp.object_id)
	DROP SECURITY POLICY [' + @SecuritySchema + '].[' + @SecurityPolicyName + ']
'
PRINT @sql