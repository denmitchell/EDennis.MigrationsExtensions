/****** Object:  StoredProcedure [_maintenance].[Temporal_GetMetadataFromExtProp]    Script Date: 2/25/2018 4:33:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================
-- Author:      Dennis Mitchell
-- Create date: 2018-02-24
-- Description: Gets temporal metadata from extended properties
-- ===========================================================================
CREATE PROCEDURE [_maintenance].[Temporal_GetMetadataFromExtProp]
AS
BEGIN

	--
	-- BUILD A TABLE OF EXISTING SYSTEM TIME COMPONENTS (RELEVANT SCHEMAS, TABLES, AND COLUMNS)
	--
	with SysStart as
	(
		select s.name SchemaName, t.name TableName, c.name ColumnName
			from sys.extended_properties ep
			inner join sys.columns as c 
				on ep.major_id = c.object_id AND ep.minor_id = c.column_id
			inner join sys.tables as t 
				on t.object_id = c.object_id 
			inner join sys.schemas as s 
				on s.schema_id = t.schema_id
			where ep.class_desc = N'OBJECT_OR_COLUMN' and ep.name = 'SystemTimeComponent' and ep.value = 'SystemStartTimeColumn'
	),
	SysEnd as
	(
		select s.name SchemaName, t.name TableName, c.name ColumnName
			from sys.extended_properties ep
			inner join sys.columns as c 
				on ep.major_id = c.object_id AND ep.minor_id = c.column_id
			inner join sys.tables as t 
				on t.object_id = c.object_id 
			inner join sys.schemas as s 
				on s.schema_id = t.schema_id
			where ep.class_desc = N'OBJECT_OR_COLUMN' and ep.name = 'SystemTimeComponent' and ep.value = 'SystemEndTimeColumn'
	),
	TT as
	(
		select s1.name TemporalTableSchema, t1.name TemporalTableName, s2.name HistoryTableSchema, t2.name HistoryTableName
			from sys.tables t1
			inner join sys.schemas s1
				on s1.schema_id = t1.schema_id 
			inner join sys.extended_properties ep1
				on ep1.major_id = t1.object_id
					and ep1.name = 'SystemTimeComponent'
					and ep1.value = 'TemporalTable'
					and ep1.class_desc = N'OBJECT_OR_COLUMN'
					and ep1.minor_id = 0
			inner join sys.extended_properties ep2
				on ep2.name = 'SystemTimeComponent'
					and convert(varchar(255),ep2.value) like 'HistoryTableFor:' + s1.name + '.' + t1.name
					and ep2.class_desc = N'OBJECT_OR_COLUMN'
					and ep1.minor_id = 0
			inner join sys.tables t2
				on t2.object_id = ep2.major_id
			inner join sys.schemas s2
				on s2.schema_id = t2.schema_id
	)
	select TT.TemporalTableSchema, TT.TemporalTableName, TT.HistoryTableSchema,
								TT.HistoryTableName, SysStart.ColumnName, SysEnd.ColumnName
			from TT
			inner join SysStart
					on SysStart.SchemaName = TT.TemporalTableSchema
						and SysStart.TableName = TT.TemporalTableName
			inner join SysEnd
					on SysEnd.SchemaName = TT.TemporalTableSchema
						and SysEnd.TableName = TT.TemporalTableName;


END
GO


