insert into Person (PersonId,FirstName,DateOfBirth,Weight,SysUserId,SysStart) 
	values 
		(1,'Bob','1980-04-23',160,0,'2016-01-01'),
		(2,'Lisa','1981-05-24',110,0,'2016-02-02');

insert into Address (PersonId,AddressId,Street,SysUserId,SysStart)
	values
		(1,1,'123 Main Street',0,'2016-03-03'),
		(2,2,'321 Second Avenue;',0,'2016-04-04');