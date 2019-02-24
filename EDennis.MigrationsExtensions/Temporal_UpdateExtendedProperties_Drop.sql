if exists (select 0 from sysobjects where id = object_id(N'_.Temporal_UpdateExtendedProperties'))
	drop procedure _.Temporal_UpdatedExtendedProperties;
