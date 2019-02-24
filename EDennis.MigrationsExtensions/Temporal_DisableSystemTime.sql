/****** Object:  StoredProcedure [_].[Temporal_DisableSystemTime]    Script Date: 2/25/2018 4:32:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================
-- Author:      Dennis Mitchell
-- Create date: 2018-02-24
-- Description: Disables system time for all temporal tables in the current
--              database.  Prior to disabling, you should call 
--				Temporal_UpdateExtendedProperties to preserve temporal 
--              metadata as extended properties of tables and columns
-- ===========================================================================
CREATE PROCEDURE [_].[Temporal_DisableSystemTime]
AS
BEGIN

    declare @tt table (
            TemporalTableSchema varchar(30),
            TemporalTableName varchar(255),
            HistoryTableSchema varchar(30),
            HistoryTableName varchar(255),
            SysStartColumnName varchar(255),
            SysEndColumnName varchar(255)
    );
	
	insert into @tt exec _.Temporal_GetMetadataFromInfoSchema
		

	declare @TemporalTableSchema varchar(255), @TemporalTableName varchar(255)

    --
    -- DISABLE SYSTEM TIME
    --
		declare c_tt cursor for
				select TemporalTableSchema, TemporalTableName
						from @tt;
 
		declare @sql varchar(max)

		open c_tt
		fetch next from c_tt into @TemporalTableSchema, @TemporalTableName
		while @@FETCH_STATUS = 0
		begin
				if @TemporalTableName is not null
				begin
						set @sql = 'alter table [' + @TemporalTableSchema + '].[' + @TemporalTableName + '] set (system_versioning = off);'         
						exec(@sql)
						set @sql = 'alter table [' + @TemporalTableSchema + '].[' + @TemporalTableName + '] drop period for system_time;'           
						exec(@sql)
				end
				fetch next from c_tt into @TemporalTableSchema, @TemporalTableName
		end

		close c_tt
		deallocate c_tt

end;
GO


