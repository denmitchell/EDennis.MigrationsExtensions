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
 


		declare @TableSchema varchar(55)
		declare @TableName varchar(200)
		declare @SecurityPolicyName varchar(255)
		
		declare @cnt int = 0;
		declare @sql varchar(max)
		declare @val varchar(255), @name varchar(255)
  

		--
		-- CREATE SECURITY SCHEMA
		--
		set @sql = 'create schema ' +  @SecuritySchema

		if not exists (select name from sys.schemas where name = @SecuritySchema)
		begin
			exec(@sql);
		end


		--
		-- CREATE SECURITY PREDICATE FUNCTION
		--
		set @sql = 'SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================
-- Author:		Dennis Mitchell
-- Create date: 2019-09-26
-- Description:	Create a filter predicate for HOST_NAME()
--              If the login user is sa, allow all operations
-- ==========================================================

CREATE OR ALTER FUNCTION [' + @SchemaName + '].HostNameSecurityPredicate(@HostName AS sysname)  
	RETURNS TABLE  
WITH SCHEMABINDING  
AS  
	RETURN SELECT 1 AS fn_HostNameSecurityPredicate
		WHERE @HostName = HOST_NAME()
		OR ORIGINAL_LOGIN() = ''sa'';

GO
'
		
		exec(@sql);


		--
		-- ITERATE OVER ALL TABLES THAT NEED THE SECURITY POLICY APPLIED
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


                     --
                     --  ADD SECURITY POLICY FOR TABLE
                     --

							set @sql = '
-- ==========================================================
-- Author:		Dennis Mitchell
-- Create date: 2019-09-26
-- Description:	Create security policy for a given table,
--              applying HostNameSecurityPredicate
-- ==========================================================
CREATE SECURITY POLICY [' + @SecuritySchema + '].[' + @SecurityPolicyName + ']  
	ADD FILTER PREDICATE [' + @SecuritySchema + '].[HostNameSecurityPredicate](' + @FilterColumnName + ')
		ON [' + @SchemaName + '].[' + @TableName + '],  
	ADD BLOCK PREDICATE [' + @SecuritySchema + '].[HostNameSecurityPredicate](' + @FilterColumnName + ')
        ON [' + @SchemaName + '].[' + @TableName + '] AFTER INSERT
	WITH (STATE = ON);
'

						exec(@sql)


                     --
                     --  GRANT SELECT ON PREDICATE FOR VARIOUS USERS
                     --

						set @sql = '
GRANT SELECT ON [' + @SecuritySchema + '].[HostNameSecurityPredicate] TO [' + ORIGINAL_LOGIN() + ']
GRANT SELECT ON [' + @SecuritySchema + '].[HostNameSecurityPredicate] TO db_owner
GRANT SELECT ON [' + @SecuritySchema + '].[HostNameSecurityPredicate] TO db_reader
GRANT SELECT ON [' + @SecuritySchema + '].[HostNameSecurityPredicate] TO db_writer
GRANT SELECT ON [' + @SecuritySchema + '].[HostNameSecurityPredicate] TO sa
'
							
						exec(@sql)

                     end
                     fetch next from c_table into @TableSchema, @TableName, @SecurityPolicyName
              end
              close c_table
              deallocate c_table
 

 
END