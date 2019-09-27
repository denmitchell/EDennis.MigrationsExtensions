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
CREATE PROCEDURE [_].[CreateHostNameRowLevelSecurity_Drop](
	@FilterColumnName varchar(255) = 'Filter',
	@SecuritySchema varchar(255) = '_security'
)
AS
BEGIN


		declare @TableSchema varchar(55)
		declare @TableName varchar(200)
		declare @SecurityPolicyName varchar(255)
		
		declare @sql varchar(max)

		--
		-- ITERATE OVER ALL TABLES 
		--
      
		declare c_table cursor for
              select distinct TABLE_NAME TableSchema, TABLE_NAME TableName,
					TableSchema + '_' + TableName + '_HostNameSecurityPolicy' SecurityPolicyName
                     from information_schema.COLUMNS c
                     where COLUMN_NAME = @FilterColumnName
					     AND COLUMN_DEFAULT LIKE '%HOST_NAME()%'
 
		open c_table
		fetch next from c_table into @TableSchema, @TableName, @SecurityPolicyName
              while @@fetch_status = 0
              begin
                     if @TableName is not null
                     begin
	                     print @TableSchema + ',' + @TableName

                     --
                     --  DROP SECURITY POLICY FOR TABLE, IF IT EXISTS
                     --

						IF EXISTS (SELECT 0	FROM sys.security_predicates sp WHERE OBJECT_ID(@SecurityPredicateName) = sp.object_id)
							BEGIN
								set @sql = '
IF EXISTS (SELECT 0 FROM sys.security_predicates sp WHERE OBJECT_ID(''[' + @SecuritySchema + '].[' + @SecurityPolicyName + ']'') = sp.object_id)
	DROP SECURITY POLICY [' + @SecuritySchema + '].[' + @SecurityPolicyName + ']';

								exec(@sql);
							END


                     end
                     fetch next from c_table into @TableSchema, @TableName, @SecurityPolicyName
              end
              close c_table
              deallocate c_table
 
		--
		-- DROP SECURITY PREDICATE FUNCTION
		--
		set @sql = 'DROP FUNCTION IF EXISTS [' + @SecuritySchema + '].HostNameSecurityPredicate'
		
		exec(@sql);



		--
		-- DROP SECURITY SCHEMA IF IT ISN'T BEING USED BY ANY OBJECTS IN THE DATABASE
		--
		if not exists(select 0 from sys.objects where schema_id = schema_id('[' + @SecuritySchema + ']'))
		begin
			set @sql = 'DROP SCHEMA IF EXISTS [' + @SecuritySchema + ']'
			exec(@sql);			
		end
 
END