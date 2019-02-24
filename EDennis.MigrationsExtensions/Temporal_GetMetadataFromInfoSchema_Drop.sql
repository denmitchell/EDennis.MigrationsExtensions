if exists (select 0 from sysobjects where id = object_id(N'_.Temporal_GetMetadataFromInfoSchema'))
	drop procedure _.Temporal_GetMetadataFromInfoSchema;
