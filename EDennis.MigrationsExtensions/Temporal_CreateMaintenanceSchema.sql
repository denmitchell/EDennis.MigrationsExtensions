if not exists (select name from sys.schemas where name = '_maintenance')
begin
	exec('create schema _maintenance');
end