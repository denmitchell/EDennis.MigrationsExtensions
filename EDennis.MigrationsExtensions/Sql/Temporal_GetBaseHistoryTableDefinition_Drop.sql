if exists (select 0 from sysobjects where id = object_id(N'_.Temporal_GetBareBonesTableDefinition'))
	drop function _.Temporal_GetBareBonesTableDefinition;
