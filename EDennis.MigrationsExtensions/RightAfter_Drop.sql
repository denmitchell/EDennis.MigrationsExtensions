if exists (select 0 from sysobjects where id = object_id(N'_.RightAfter'))
	drop function _.RightAfter;
