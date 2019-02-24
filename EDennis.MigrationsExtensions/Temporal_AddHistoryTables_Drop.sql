if exists (select 0 from sysobjects where id = object_id(N'_.Temporal_AddHistoryTables'))
	drop procedure _.Temporal_AddHistoryTables;
