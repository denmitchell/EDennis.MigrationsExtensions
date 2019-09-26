if exists (select 0 from sysobjects where id = object_id(N'_.CreateHostNameRowLevelSecurity_Drop'))
	drop procedure _.CreateHostNameRowLevelSecurity_Drop;
if exists (select 0 from sysobjects where id = object_id(N'_.CreateHostNameRowLevelSecurity'))
	drop procedure _.CreateHostNameRowLevelSecurity;
