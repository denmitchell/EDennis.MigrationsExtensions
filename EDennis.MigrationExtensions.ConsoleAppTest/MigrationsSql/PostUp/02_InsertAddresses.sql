insert into xxx.Address (PersonId,Street,SysUser)
	select PersonId,'123 Main Street','alice'
		from xxx.Person where Id = 1;

insert into xxx.Address (PersonId,Street,SysUser)
	select PersonId,'321 Second Avenue','alice'
		from xxx.Person where Id = 2;