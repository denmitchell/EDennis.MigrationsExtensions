declare @SecuritySchema varchar(500) = '@SecuritySchema';
declare @SqlRoleOrUser varchar(500) = '@SqlRoleOrUser';
declare @sql varchar(max) = 'GRANT SELECT ON [' + @SecuritySchema + '].[HostNameSecurityPredicate] TO [' + @SqlRoleOrUser + ']
GRANT SELECT ON [' + @SecuritySchema + '].[HostNameSecurityPredicate] TO db_owner
GRANT SELECT ON [' + @SecuritySchema + '].[HostNameSecurityPredicate] TO db_reader
GRANT SELECT ON [' + @SecuritySchema + '].[HostNameSecurityPredicate] TO sa
'
PRINT @sql