if exists (select 0 from sysobjects where id = object_id(N'_.Temporal_DisableSystemTime'))
	drop procedure _.Temporal_DisableSystemTime;
