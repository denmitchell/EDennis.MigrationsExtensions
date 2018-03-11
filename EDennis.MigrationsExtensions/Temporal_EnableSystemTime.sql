/****** Object:  StoredProcedure [_maintenance].[Temporal_EnableSystemTime]    Script Date: 2/25/2018 4:32:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================
-- Author:      Dennis Mitchell
-- Create date: 2018-02-24
-- Description: Enables system time for all temporal tables in the current
--              database.  Note: this relies upon the presence of 
--              extended properties with the name 'SystemTimeComponent'
-- ===========================================================================
CREATE PROCEDURE [_maintenance].[Temporal_EnableSystemTime] 
AS
BEGIN

		declare @HistoryTableSchema varchar(255)
		declare @TemporalTableSchema varchar(255)
		declare @TemporalTableName varchar(255), @HistoryTableName varchar(255)
		declare @SysStartColumnName varchar(255), @SysEndColumnName varchar(255) 
		declare @sql varchar(max)

	--
	-- BUILD A TABLE OF EXISTING SYSTEM TIME COMPONENTS (RELEVANT SCHEMAS, TABLES, AND COLUMNS)
	--
       declare @tt1 table (
              TemporalTableSchema varchar(30),
              TemporalTableName varchar(255),
              HistoryTableSchema varchar(30),
              HistoryTableName varchar(255),
              SysStartColumnName varchar(255),
              SysEndColumnName varchar(255)
       );
       declare @tt2 table (
              TemporalTableSchema varchar(30),
              TemporalTableName varchar(255),
              HistoryTableSchema varchar(30),
              HistoryTableName varchar(255),
              SysStartColumnName varchar(255),
              SysEndColumnName varchar(255)
       );
       declare @tt table (
              TemporalTableSchema varchar(30),
              TemporalTableName varchar(255),
              HistoryTableSchema varchar(30),
              HistoryTableName varchar(255),
              SysStartColumnName varchar(255),
              SysEndColumnName varchar(255)
       );
	   insert into @tt1 exec _maintenance.Temporal_GetMetadataFromExtProp
	   insert into @tt2 exec _maintenance.Temporal_GetMetadataFromInfoSchema

	   insert into @tt select * from @tt1 except select * from @tt2


    --
    -- ENABLE SYSTEM TIME
    --
		declare @ConstraintName varchar(255)

		declare c_tt cursor for
			select TemporalTableSchema, TemporalTableName, HistoryTableSchema, 
					HistoryTableName, SysStartColumnName, SysEndColumnName 
					from @tt
					
		open c_tt
		fetch next from c_tt into @TemporalTableSchema, @TemporalTableName, @HistoryTableSchema, 
					@HistoryTableName, @SysStartColumnName, @SysEndColumnName
		while @@fetch_status = 0
		begin
			if @TemporalTableSchema is not null
			begin
				declare c_constraints cursor for
					select dc.name ConstraintName
						from sys.default_constraints dc
						inner join sys.columns c
							on c.default_object_id = dc.object_id
						inner join sys.tables t
							on t.object_id = c.object_id
						inner join sys.schemas s
							on s.schema_id = t.schema_id
						where c.name = @SysStartColumnName
							and s.name = @TemporalTableSchema
							and t.name = @TemporalTableName
					union
					select dc.name ConstraintName
						from sys.default_constraints dc
						inner join sys.columns c
							on c.default_object_id = dc.object_id
						inner join sys.tables t
							on t.object_id = c.object_id
						inner join sys.schemas s
							on s.schema_id = t.schema_id
						where c.name = @SysEndColumnName
							and s.name = @TemporalTableSchema
							and t.name = @TemporalTableName
				open c_constraints
				fetch next from c_constraints into @ConstraintName
				while @@fetch_status = 0
				begin
					if @ConstraintName is not null
					begin
						set @sql = 'alter table [' + @TemporalTableSchema + '].[' + @TemporalTableName + '] drop constraint ' + @ConstraintName				 
						exec(@sql)						
					end
					fetch next from c_constraints into @ConstraintName
				end
				close c_constraints
				deallocate c_constraints

				set @sql = 'alter table [' + @TemporalTableSchema + '].[' + @TemporalTableName + '] add constraint df' + @TemporalTableName + '_'+  @SysStartColumnName + ' default (getdate()) for ' + @SysStartColumnName				 
				exec(@sql)
				set @sql = 'alter table [' + @TemporalTableSchema + '].[' + @TemporalTableName + '] add constraint df' + @TemporalTableName + '_'+  @SysEndColumnName + ' default (CONVERT([datetime2],''9999-12-31 23:59:59.9999999'')) for ' + @SysEndColumnName				 
				exec(@sql)
				set @sql = 'alter table [' + @TemporalTableSchema + '].[' + @TemporalTableName + '] add period for system_time(' + @SysStartColumnName + ',' + @SysEndColumnName + ');' 
				exec(@sql)
				set @sql = 'alter table [' + @TemporalTableSchema + '].[' + @TemporalTableName + '] set (system_versioning = on (history_table = [' + @HistoryTableSchema + '].[' + @HistoryTableName + ']));' 
				exec(@sql)
			end
			fetch next from c_tt into @TemporalTableSchema, @TemporalTableName, @HistoryTableSchema, 
					@HistoryTableName, @SysStartColumnName, @SysEndColumnName
		end

		close c_tt
		deallocate c_tt

end;
GO


