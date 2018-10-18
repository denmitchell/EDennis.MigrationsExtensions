# EDennis.MigrationsExtensions
This package provides extensions to Microsoft.EntityFrameworkCore.Migrations.MigrationBuilder to support SQL Server Temporal tables and/or TestJson tables.  

When you add ```migrationBuilder.CreateMaintenanceProcedures();``` to the beginning of the Initial Migration's Up() method, the migrationBuilder generates a "_maintenance" schema (if needed) and creates a number of stored procedures that are used to maintain temporal tables.   History tables are automatically generated for all tables having the appropriate SysStart and SysEnd columns.  It is recommended to add ```migrationBuilder.DropMaintenanceProcedures();``` to the end of the Initial Migration's Drop() method.

When you add ```migrationBuilder.CreateTestJsonTableSupport();``` to the Initial Migration's Up() method, the migrationBuilder generates a "_maintenance" schema (if needed), creates a TestJson table, and creates a SaveTestJson stored procedure.   It is recommended to add ```migrationBuilder.DropTestJsonTableSupport();``` to the Initial Migration's Drop() method.

A ```migrationBuilder.DoInserts(path_to_sql_insert_file);``` method enables you to add insert statements to the end of any Up() method.  Temporal tables are disabled prior to the inserts and re-enabled after the inserts.  Also, all sequences are updated after the inserts.  It is recommended to place an INSERT file in a folder labeled MigrationsInserts and to prefix the INSERT file with the same timestamp prefix as is generated for the migration to which the INSERT file applies  (e.g., for a "20180311204507_Initial.cs" migration file, create a "20180311204507_Insert.sql" file and place it in the MigrationsInserts folder).  Importantly, insert files can have update and delete statements, as well.
