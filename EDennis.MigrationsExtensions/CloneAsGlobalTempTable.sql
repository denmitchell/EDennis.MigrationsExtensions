SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===========================================================
-- Author:		Dennis Mitchell
-- Create date: 2019-04-26
-- Description:	Creates a global temporary table based upon
--              a source table.  The global temporary table
--              does not have any constraints or identity
--              specifications.  The global temporary table
--              has a prefix '##', but otherwise has the
--              same name as the source table.  The procedure
--              also inserts all data from the source table
--              into the global temp table.
-- ===========================================================
CREATE OR ALTER PROCEDURE [_].[CloneAsGlobalTempTable](
	@SourceTableName varchar(255),
	@SourceTableSchema varchar(255) = 'dbo'
) 
AS
BEGIN
if @SourceTableSchema is null
	set @SourceTableSchema = 'dbo'

declare @tempTableName varchar(255)
set @tempTableName = '##' + @SourceTableName


	
declare @sql nvarchar(max)


if object_id('tempdb..' + @tempTableName) is not null
	begin
		set @sql = 'drop table ' + @tempTableName
		exec sp_executesql @sql
		set @sql = ''
	end


set @sql =  'create table ' + @tempTableName  +  ' ( '

declare @colDef varchar(max)
declare c_coldef cursor for
	select  
        '[' + c.column_name + '] '
         + case when c.data_type = 'real' then 'float' else c.data_type end  
		 + case 
			when c.datetime_precision is not null and c.datetime_precision > 0 and c.data_type in ('datetime2') 
				then '(' + convert(varchar,c.datetime_precision) + ')'
			when c.character_maximum_length is not null 
				then case 
					when c.data_type in ('text','ntext') 
						then ''
					when c.character_maximum_length = -1
						then '(max)'
					else '(' + convert(varchar,c.character_maximum_length) + ')'
					end
			when c.numeric_precision is not null and c.data_type not in ('int','bigint','tinyint','smallint','time','money','smallmoney')
				then case 
					when c.numeric_scale is null 
						then '(' + convert(varchar,c.numeric_precision) + ')'
					else '(' + convert(varchar,c.numeric_precision) + ',' + convert(varchar,c.numeric_scale) + ')'
					end
			else ''
			end
		+ case
			when c.is_nullable = 'NO'
				then ' NOT' 
				else '' 
			end + ' NULL' 
		--+ case 
		--	when c.column_default is not null
		--		then ' DEFAULT (' + c.column_default + ')'
		--		else ''
		--	end
		+ ',' ColDef
		from information_schema.columns c
		where c.table_schema = @SourceTableSchema and c.table_name = @SourceTableName 
		order by ordinal_position

open c_coldef
fetch next from c_coldef into @colDef
while @@fetch_status = 0
	begin
		if @colDef is not null
			begin
				set @sql = @sql + @colDef
            end
        fetch next from c_coldef into @colDef
    end
close c_coldef
deallocate c_coldef

set @sql =  @sql + ');'


exec sp_executesql @sql

set @sql = 'insert into ' + @tempTableName + ' select * from [' + @SourceTableSchema + '].[' + @SourceTableName + ']'
exec sp_executesql @sql

END

