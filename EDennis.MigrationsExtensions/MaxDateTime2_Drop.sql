if exists (select 0 from sysobjects where id = object_id(N'_.MaxDateTime2'))
	drop function _.MaxDateTime2
