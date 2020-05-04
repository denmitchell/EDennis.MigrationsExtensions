if exists (select 0 from sysobjects where id = object_id(N'_.TestJson'))
begin
	alter table _.TestJson set (system_versioning = off);
	drop table _.TestJson;
end
