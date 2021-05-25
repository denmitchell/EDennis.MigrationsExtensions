# EDennis.MigrationsExtensions
This package provides extensions to Microsoft.EntityFrameworkCore.Migrations.MigrationBuilder to support **SQL Server Temporal Tables** and/or **TestJson Tables**.  _NOTE: to use any of these extensions, you need to replace the SqlServerMigrationsSqlGenerator service with the MigrationsExtensionsSqlGenerator from this library. see [Custom Migrations Operations](https://docs.microsoft.com/en-us/ef/core/managing-schemas/migrations/operations#using-migrationbuildersql)_.

## SQL Server Temporal Tables
[SQL Server Temporal Tables](https://docs.microsoft.com/en-us/sql/relational-databases/tables/temporal-tables?view=sql-server-ver15) provide a simple way to keep historical records that have been updated or deleted through normal database operations. Generating SQL Server Temporal Tables during Migrations is fairly straightforward. For any given entity that has SysStart (datetime2) and SysEnd (datetime2) properties, when you add ```modelBuilder.Entity<SomeClass>(e => { e.HasAnnotation("SystemVersioned", true);``` to OnModelCreating, a SQL Server Temporal Table and history table are automatically created.  The history table has the same name as the temporal table but resides in a new schema suffixed by _history.

## TestJson Tables
[TestJson Tables](https://github.com/denmitchell/EDennis.NetCoreTestingUtilities) provide a way to store test cases (input parameters and expected output) in a database table.  It only takes one line of code in a Migrations class to generate a TestJson table.  When you add ```migrationBuilder.CreateTestJsonTableSupport();``` to the Initial Migration's Up() method, the migrationBuilder generates a "_" schema (if needed), creates a TestJson table, and creates a SaveTestJson stored procedure.   It is recommended to add ```migrationBuilder.DropTestJsonTableSupport();``` to the Initial Migration's Drop() method.

## Table/Class and Column/Property Mappings
When you add ```migrationBuilder.SaveMappings();``` to the end of the Initial Migration's Up() method, the migrationBuilder saves table<->class mappings and column<->property mappings as SQL Server extended properties.  These extended properties are useful when you need to determine class names and property names from the information schema.  The EDennis.DataScaffolder Win Forms app will use these extended properties, when they are available.

## Helpful Stored Procedures for Testing
When you add ```migrationBuilder.CreateMaintenanceProcedures();``` to the beginning of the Initial Migration's Up() method, the migrationBuilder generates a "_" schema (if needed) and creates a number of helpful stored procedures and functions: (a) ResetIdentities, which ensures that the next value for each identity specification is the maximum of the Id associated with the identity spec; (b) ResetSequences, which is similar to ResetIdentities, but with sequences; (c) GetMappings, which returns all entity framework mappings generated by the SaveMappings operation; (d) MaxDateTime2, which returns the maximum datimetime2 value; (e) RightBefore, which gets the datetime2 value that is 100 nanoseconds before the provided datetime2 parameter; and (f) RightAfter, which gets the datetime2 value that is 100 nanoseconds after the provided datetime2 parameter.  It is recommended to add ```migrationBuilder.DropMaintenanceProcedures();``` to the end of the Initial Migration's Drop() method.

