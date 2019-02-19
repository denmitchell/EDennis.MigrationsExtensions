use PersonAddress01;
declare @Input varchar(max) = (
select 
	'Joe' FirstName,
	'1990-01-01' DateOfBirth,
	160 Weight
	for json path, without_array_wrapper
)
declare @Expected varchar(max)  = (
	select * from Person
	for json path
)
exec _maintenance.ResetSequences
exec _maintenance.SaveTestJson 'EDennis.MigrationsExtensions', 'StoredProcedure', 'GetTestJson','GetTestJson','A','Input', @Input
exec _maintenance.SaveTestJson 'EDennis.MigrationsExtensions', 'StoredProcedure', 'GetTestJson','GetTestJson','A','Expected', @Expected

exec _maintenance.GetTestJson 'EDennis.MigrationsExtensions', 'StoredProcedure', 'GetTestJson','GetTestJson','A'