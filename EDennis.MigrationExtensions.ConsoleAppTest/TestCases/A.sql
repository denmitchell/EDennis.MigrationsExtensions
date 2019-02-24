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
exec _.ResetSequences
exec _.SaveTestJson 'EDennis.MigrationsExtensions', 'StoredProcedure', 'GetTestJson','GetTestJson','A','Input', @Input
exec _.SaveTestJson 'EDennis.MigrationsExtensions', 'StoredProcedure', 'GetTestJson','GetTestJson','A','Expected', @Expected

exec _.GetTestJson 'EDennis.MigrationsExtensions', 'StoredProcedure', 'GetTestJson','GetTestJson','A'
