if not exists (select name from sys.schemas where name = '_')
begin
	exec('create schema _');
end