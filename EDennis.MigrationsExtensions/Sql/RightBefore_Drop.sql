if exists (select 0 from sysobjects where id = object_id(N'_.RightBefore'))
	drop function _.RightBefore;
