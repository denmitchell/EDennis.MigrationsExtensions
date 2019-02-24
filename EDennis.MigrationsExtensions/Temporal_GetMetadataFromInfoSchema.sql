/****** Object:  StoredProcedure [_].[Temporal_GetMetadataFromInfoSchema]    Script Date: 2/25/2018 4:33:46 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================
-- Author:      Dennis Mitchell
-- Create date: 2018-02-24
-- Description: Gets temporal metadata from the information_schema view 
-- ===========================================================================
CREATE PROCEDURE [_].[Temporal_GetMetadataFromInfoSchema]
AS
BEGIN

--
-- BUILD A TABLE OF EXISTING SYSTEM TIME COMPONENTS (RELEVANT SCHEMAS, TABLES, AND COLUMNS)
--
    with SysStart as
    (
    select s.name SchemaName, t.name TableName, c.name ColumnName
            ,[column_id]     
            ,[generated_always_type]
            ,[generated_always_type_desc]
            FROM sys.columns c
            inner join sys.objects o
                    on o.object_id = c.object_id
            inner join sys.tables t
                    on o.object_id = t.object_id
            inner join sys.schemas s
                    on t.schema_id = s.schema_id
            where generated_always_type = 1
    ),
    SysEnd as
    (
    select s.name SchemaName, t.name TableName, c.name ColumnName
            ,[column_id]     
            ,[generated_always_type]
            ,[generated_always_type_desc]
            FROM sys.columns c
            inner join sys.objects o
                    on o.object_id = c.object_id
            inner join sys.tables t
                    on o.object_id = t.object_id
            inner join sys.schemas s
                    on t.schema_id = s.schema_id
            where generated_always_type = 2
    ),
    TT as
    (
            select tts.name TemporalTableSchema, tt.name TemporalTableName, hts.name HistoryTableSchema, ht.name HistoryTableName
                    from sys.tables tt
                    inner join sys.schemas tts
                        on tts.schema_id = tt.schema_id
                    inner join sys.tables ht
                        on tt.history_table_id = ht.object_id
                    inner join sys.schemas hts
                        on hts.schema_id = ht.schema_id
                    where tt.temporal_type = 2
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


