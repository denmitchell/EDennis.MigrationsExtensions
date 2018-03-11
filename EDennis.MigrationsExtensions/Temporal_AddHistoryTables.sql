/****** Object:  StoredProcedure [_maintenance].[Temporal_AddHistoryTables]    Script Date: 2/27/2018 3:01:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================
-- Author:      Dennis Mitchell
-- Create date: 2018-02-24
-- Description: Adds new history tables that are missing from schema
-- ===========================================================================
CREATE PROCEDURE [_maintenance].[Temporal_AddHistoryTables](
       @AutoEnable BIT = 1
)
AS
BEGIN
 
       declare @TemporalTableSchema varchar(255) = 'dbo'
       declare @HistoryTableSchema varchar(255) = 'dbo_history'
       declare @SysStartColumnName varchar(255), @SysEndColumnName varchar(255)
       declare @TemporalTableName varchar(255), @HistoryTableName varchar(255)
       declare @cnt int = 0;
       declare @sql varchar(max)
       declare @val varchar(255), @name varchar(255)
 
 
       --
       -- GET TEMPORAL METADATA FROM INFORMATION_SCHEMA AND EXTENDED PROPERTIES
       --
 
              declare @tt table (
                           TemporalTableSchema varchar(30),
                           TemporalTableName varchar(255),
                           HistoryTableSchema varchar(30),
                           HistoryTableName varchar(255),
                           SysStartColumnName varchar(255),
                           SysEndColumnName varchar(255)
              );
      
              insert into @tt exec _maintenance.Temporal_GetMetadataFromInfoSchema
              insert into @tt exec _maintenance.Temporal_GetMetadataFromExtProp
 
              declare @th table(
                     TemporalTableSchema varchar(30),
                     HistoryTableSchema varchar(30)
              );
 
 
       --
       -- INSERT DEFAULT HISTORY SCHEMAS FOR DBO AND OTHER SCHEMAS
       --
 
              insert into @th(TemporalTableSchema, HistoryTableSchema)
                     select distinct TemporalTableSchema, HistoryTableSchema
                           from @tt;
 
              insert into @th(TemporalTableSchema, HistoryTableSchema)
                     select @TemporalTableSchema, @HistoryTableSchema
                           where not exists (select 0 from @th where TemporalTableSchema ='dbo')
 
              insert into @th(TemporalTableSchema, HistoryTableSchema)
                     select t.TABLE_SCHEMA, t.TABLE_SCHEMA + '_history'
                           from information_schema.tables t
                           where not exists (select 0 from @th where TemporalTableSchema = t.TABLE_SCHEMA)
 
 
       --
       -- ITERATE OVER ALL TABLES THAT NEED A HISTORY TABLE -- TABLES THAT HAVE SYSTEM TIME
       -- COLUMNS, BUT DON'T HAVE CORRESPONDING HISTORY TABLES
       --
      
       declare c_misshist cursor for
              select cStart.TABLE_SCHEMA TemporalTableSchema, cStart.TABLE_NAME TemporalTableName,
                           cStart.COLUMN_NAME SysStartColumnName, cEnd.COLUMN_NAME SysEndColumnName
                     from information_schema.COLUMNS cStart
                     left outer join @th th
                           on th.TemporalTableSchema = cStart.TABLE_SCHEMA
                     inner join (
                           select c.TABLE_SCHEMA, c.TABLE_NAME, c.COLUMN_NAME
                                  from information_schema.COLUMNS c
                                  where c.TABLE_SCHEMA = @TemporalTableSchema
                                         and c.DATA_TYPE = 'datetime2'
                                         and c.COLUMN_DEFAULT = '(CONVERT([datetime2],''9999-12-31 23:59:59.9999999''))'
                                         and c.IS_NULLABLE = 'NO'
                     ) cEnd
                           on cEnd.TABLE_SCHEMA = cStart.TABLE_SCHEMA
                                  and cEnd.TABLE_NAME = cStart.TABLE_NAME
 
                     where
                           cStart.DATA_TYPE = 'datetime2'
                                  and cStart.COLUMN_DEFAULT = '(getdate())'
                                  and cStart.IS_NULLABLE = 'NO'
                                  and not exists(
                                         select 0
                                                from @tt tt
                                                where tt.TemporalTableSchema = @TemporalTableSchema
                                                       and tt.TemporalTableName = cStart.TABLE_NAME
                                  )
 
              open c_misshist
              fetch next from c_misshist into @TemporalTableSchema, @TemporalTableName, @SysStartColumnName, @SysEndColumnName
              while @@fetch_status = 0
              begin
                     if @TemporalTableName is not null
                     begin
                     print @TemporalTableSchema + ',' + @TemporalTableName + ',' + @SysStartColumnName + ',' + @SysEndColumnName
                     --
                     -- DROP AND ADD EXTENDED PROPERTY FOR SYSTEM_START_TIME COLUMN
                     --
 
                           if exists (
                                  select 1
                                         from sys.extended_properties as ep
                                         inner join sys.columns AS c ON ep.major_id = c.object_id AND ep.minor_id = c.column_id
                                         inner join sys.tables as t on t.object_id = c.object_id
                                         inner join sys.schemas as s on s.schema_id = t.schema_id
                                         where s.name = @TemporalTableSchema and t.name=@TemporalTableName and c.name = @SysStartColumnName
                                                and ep.name = 'SystemTimeComponent'
                           )
                           begin
                                  execute sp_dropextendedproperty
                                         @name='SystemTimeComponent',
                                         @level0type = N'Schema',
                                         @level0name = @TemporalTableSchema,
                                         @level1type = N'Table',
                                         @level1name = @TemporalTableName,
                                         @level2type = N'Column',
                                         @level2name = @SysStartColumnName
                           end
 
                           execute sp_addextendedproperty
                                  @name='SystemTimeComponent',
                                  @value='SystemStartTimeColumn',
                                  @level0type = N'Schema',
                                  @level0name = @TemporalTableSchema,
                                  @level1type = N'Table',
                                  @level1name = @TemporalTableName,
                                  @level2type = N'Column',
                                  @level2name = @SysStartColumnName
 
                     --
                     --  DROP AND ADD EXTENDED PROPERTY FOR SYSTEM_END_TIME COLUMN
                     --
 
                           if exists (
                                  select 1
                                         from sys.extended_properties as ep
                                         inner join sys.columns AS c ON ep.major_id = c.object_id AND ep.minor_id = c.column_id
                                         inner join sys.tables as t on t.object_id = c.object_id
                                         inner join sys.schemas as s on s.schema_id = t.schema_id
                                         where s.name = @TemporalTableSchema and t.name=@TemporalTableName and c.name = @SysEndColumnName
                                                and ep.name = 'SystemTimeComponent'
                           )
                           begin
                                  execute sp_dropextendedproperty
                                         @name='SystemTimeComponent',
                                         @level0type = N'Schema',
                                         @level0name = @TemporalTableSchema,
                                         @level1type = N'Table',
                                         @level1name = @TemporalTableName,
                                         @level2type = N'Column',
                                         @level2name = @SysEndColumnName
                           end
 
                           execute sp_addextendedproperty
                                  @name='SystemTimeComponent',
                                  @value='SystemEndTimeColumn',
                                  @level0type = N'Schema',
                                  @level0name = @TemporalTableSchema,
                                  @level1type = N'Table',
                                  @level1name = @TemporalTableName,
                                  @level2type = N'Column',
                                  @level2name = @SysEndColumnName
 
 
                     --
                     --  CREATE HISTORY TABLE
                     --
                           declare @ErrorMessage varchar(max)
                           set @HistoryTableName = @TemporalTableName
      
                           if exists(select 0 from information_schema.tables t where t.TABLE_SCHEMA = @HistoryTableSchema and t.TABLE_NAME = @HistoryTableName )
                                  begin
                                  --
                                  -- DETERMINE IF CORRESPONDING TABLE IN HISTORY SCHEMA IS INSUFFICIENT TO USE AS HISTORY TABLE ...
                                  --
                                         if exists(
                                                select a.* from
                                                (
                                                       select c.TABLE_SCHEMA, c.TABLE_NAME, c.COLUMN_NAME, c.DATA_TYPE,
                                                                           c.IS_NULLABLE, c.CHARACTER_MAXIMUM_LENGTH, c.NUMERIC_PRECISION, C.NUMERIC_SCALE
                                                                     from INFORMATION_SCHEMA.columns c
                                                                     where c.TABLE_SCHEMA = @TemporalTableSchema
                                                                           and c.TABLE_NAME = @TemporalTableName
                                                       except
                                                       select c.TABLE_SCHEMA, c.TABLE_NAME, c.COLUMN_NAME, c.DATA_TYPE,
                                                                           c.IS_NULLABLE, c.CHARACTER_MAXIMUM_LENGTH, c.NUMERIC_PRECISION, C.NUMERIC_SCALE
                                                                     from INFORMATION_SCHEMA.columns c
                                                                     where c.TABLE_SCHEMA = @HistoryTableSchema
                                                                           and c.TABLE_NAME = @HistoryTableName
                                                ) a
                                                union select b.* from
                                                (
                                                       select c.TABLE_SCHEMA, c.TABLE_NAME, c.COLUMN_NAME, c.DATA_TYPE,
                                                                           c.IS_NULLABLE, c.CHARACTER_MAXIMUM_LENGTH, c.NUMERIC_PRECISION, C.NUMERIC_SCALE
                                                                     from INFORMATION_SCHEMA.columns c
                                                                     where c.TABLE_SCHEMA = @TemporalTableSchema
                                                                           and c.TABLE_NAME = @TemporalTableName
                                                       except
                                                       select c.TABLE_SCHEMA, c.TABLE_NAME, c.COLUMN_NAME, c.DATA_TYPE,
                                                                           c.IS_NULLABLE, c.CHARACTER_MAXIMUM_LENGTH, c.NUMERIC_PRECISION, C.NUMERIC_SCALE
                                                                     from INFORMATION_SCHEMA.columns c
                                                                     where c.TABLE_SCHEMA = @HistoryTableSchema
                                                                           and c.TABLE_NAME = @HistoryTableName
                                                ) b
                                         )
                                         raiserror(
                                                N'A NOTE: Cannot Use %s.%s as history table for %s.%s.  The table definitions are not parallel.',
                                                11, --Fatal
                                                1, --State
                                                @HistoryTableSchema,
                                                @HistoryTableName,
                                                @TemporalTableSchema,
                                                @TemporalTableName
                                         );
 
 
 
                                  end  
                                  else
                                  begin
                                  --
                                  -- CREATE HISTORY TABLE FROM TEMPORAL TABLE DEFINITION
                                  --
                                         begin try
                                                if not exists (select 1 from sys.schemas where name = @HistoryTableSchema)
                                                       exec ('create schema [' +  @HistoryTableSchema +']')
                                                exec ('select * into [' + @HistoryTableSchema +'].[' + @HistoryTableName + '] from [' + @TemporalTableSchema +'].[' + @TemporalTableName + '] where 0 = 1')
                                         end try
                                         begin catch
                                                set @ErrorMessage = ERROR_MESSAGE()
                                                raiserror(
                                                       N'A NOTE: Cannot Use %s.%s as history table for %s.%s.  %s',
                                                       11, --Fatal
                                                       1, --State
                                                       @TemporalTableSchema,
                                                       @TemporalTableName,
                                                       @HistoryTableSchema,
                                                       @HistoryTableName,
                                                       @ErrorMessage
                                                );
                                         end catch
 
 
                                  end
 
 
                     --
                     --  ADD EXTENDED PROPERTY FOR HISTORY TABLE
                     --
                           set @val = 'HistoryTableFor:' + @TemporalTableSchema + '.' + @TemporalTableName
                           execute sp_addextendedproperty
                                  @name='SystemTimeComponent',
                                  @value=@val,
                                  @level0type = N'Schema',
                                  @level0name = @HistoryTableSchema,
                                  @level1type = N'Table',
                                  @level1name = @HistoryTableName
 
 
                     --
                     --  ADD EXTENDED PROPERTY FOR TEMPORAL TABLE
                     --
                           if not exists (
                                  select ep.major_id, ep.minor_id, s.name AS SchemaName, t.name as TableName, ep.name as ExtendedPropertyName, ep.value as ExtendedPropertyValue
                                         from sys.extended_properties as ep
                                         inner join sys.tables as t on ep.major_id = t.object_id
                                         inner join sys.schemas as s on s.schema_id = t.schema_id
                                         where s.name = @TemporalTableSchema and t.name=@TemporalTableName and ep.name = 'SystemTimeComponent' and ep.value = 'TemporalTable'
                           )
                           execute sp_addextendedproperty
                                  @name='SystemTimeComponent',
                                  @value='TemporalTable',
                                  @level0type = N'Schema',
                                  @level0name = @TemporalTableSchema,
                                  @level1type = N'Table',
                                  @level1name = @TemporalTableName
 
 
                     end
                     fetch next from c_misshist into @TemporalTableSchema, @TemporalTableName, @SysStartColumnName, @SysEndColumnName
              end
              close c_misshist
              deallocate c_misshist
 
              --
              -- ENABLE SYSTEM TIME IF AUTO-ENABLED
              --
              if @AutoEnable = 1
                     exec _maintenance.Temporal_EnableSystemTime
 
END