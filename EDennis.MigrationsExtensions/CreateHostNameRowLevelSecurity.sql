/****** Object:  StoredProcedure [_].[Temporal_AddHistoryTables]    Script Date: 2/27/2018 3:01:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================
-- Author:      Dennis Mitchell
-- Create date: 2018-02-24
-- Description: Adds Row-level security based upon HOST_NAME()
-- ===========================================================================
CREATE PROCEDURE [_].[CreateHostNameRowLevelSecurity](
	@FilterColumnName varchar(255) = 'Filter',
	@SecuritySchema varchar(255) = '_security'
)
AS
BEGIN
 


		declare @TableSchema varchar(255)
		declare @TableName varchar(255)
		declare @SecurityPredicateName varchar(255)
		
		declare @cnt int = 0;
		declare @sql varchar(max)
		declare @val varchar(255), @name varchar(255)
  

		--
		-- CREATE SECURITY PREDICATE FUNCTION
		--

		exec _.HostNameSecurityPredicate


		--
		-- ITERATE OVER ALL TABLES THAT NEED THE SECURITY POLICY APPLIED
		--
      
		declare c_table cursor for
              select distinct TABLE_NAME TableSchema, TABLE_NAME TableName,
					TableSchema + '_' + TableName + '_SecurityPredicate' SecurityPredicateName
                     from information_schema.COLUMNS c
                     where COLUMN_NAME = @FilterColumnName
					     AND COLUMN_DEFAULT LIKE '%HOST_NAME()%'
 
		open c_table
		fetch next from c_table into @TableSchema, @TableName, @SecurityPredicateName
              while @@fetch_status = 0
              begin
                     if @TableName is not null
                     begin
                     print @TableSchema + ',' + @TableName

                     --
                     --  CREATE HISTORY TABLE
                     --

					-- Drop existing security filters
						IF EXISTS (SELECT 0	FROM sys.security_predicates sp WHERE OBJECT_ID(@SecurityPredicateName) = sp.object_id)
							BEGIN
								set @sql = 'DROP SECURITY POLICY [' + @TableSchema' dbo].[CourseFilter]
							END
							

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
													begin
														exec ('create schema [' + @HistoryTableSchema + '];');
													end
													declare @tblsql varchar(max) = 
														_.Temporal_GetBaseHistoryTableDefinition(
															@TemporalTableSchema, @TemporalTableName, 
															@HistoryTableSchema, @HistoryTableName)
													exec (@tblsql)
                                         end try
                                         begin catch
                                                set @ErrorMessage = ERROR_MESSAGE()
                                                raiserror(
                                                       N'A NOTE: Cannot Use %s.%s as history table for %s.%s.  %s',
                                                       11, --Fatal
                                                       1, --State
                                                       @HistoryTableSchema,
                                                       @HistoryTableName,
                                                       @TemporalTableSchema,
                                                       @TemporalTableName,
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
                     fetch next from c_misshist into @TemporalTableSchema, @TemporalTableName, @SysStartColumnName, @SysEndColumnName, @HistoryTableSchema, @HistoryTableName
              end
              close c_misshist
              deallocate c_misshist
 
              --
              -- ENABLE SYSTEM TIME IF AUTO-ENABLED
              --
              if @AutoEnable = 1
                     exec _.Temporal_EnableSystemTime
 
END