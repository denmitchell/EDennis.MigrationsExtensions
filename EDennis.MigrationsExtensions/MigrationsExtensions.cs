using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Microsoft.EntityFrameworkCore.Migrations;
using System.IO;
using System.Linq;
using System.Reflection;

namespace EDennis.MigrationsExtensions
{

    /// <summary>
    /// These extensions to MigrationBuilder facilitate working with SQL Server 
    /// temporal tables.
    /// </summary>
    public static class MigrationsExtensions {

        /// <summary>
        /// Saves class-table/property-column mappings to extended properties in SQL Server.
        /// </summary>
        /// <param name="migrationBuilder"></param>
        /// <returns></returns>
        public static MigrationBuilder SaveMappings(this MigrationBuilder migrationBuilder) {
            migrationBuilder.Operations.Add(
                new SaveMappingsOperation());
            return migrationBuilder;
        }


        public static ModelBuilder DropForeignKeys(this ModelBuilder modelBuilder) {
            var entityTypes = modelBuilder.Model.GetEntityTypes().ToList();
            for (int i = 0; i < entityTypes.Count(); i++) {
                var entityType = entityTypes[i];
                var foreignKeys = entityType.GetForeignKeys().ToList();
                for (int j = 0; j < foreignKeys.Count(); j++) {
                    var fk = foreignKeys[j];
                    entityType.RemoveForeignKey(
                        fk.Properties,
                        fk.PrincipalKey,
                        fk.PrincipalEntityType);
                }
            }
            return modelBuilder;
        }

        public static EntityTypeBuilder DropForeignKeys<TEntity>(this EntityTypeBuilder<TEntity> entityTypeBuilder)
            where TEntity : class {
            var foreignKeys = entityTypeBuilder.Metadata.GetForeignKeys().ToList();
            for (int j = 0; j < foreignKeys.Count(); j++) {
                var fk = foreignKeys[j];
                entityTypeBuilder.Metadata.RemoveForeignKey(
                    fk.Properties,
                    fk.PrincipalKey,
                    fk.PrincipalEntityType);
            }
            return entityTypeBuilder;
        }

        /// <summary>
        /// Creates SQL Server temporal tables and supporting maintenance objects
        /// </summary>
        /// <param name="migrationBuilder"></param>
        /// <returns></returns>
        public static MigrationBuilder CreateSqlServerTemporalTables(this MigrationBuilder migrationBuilder) {

            migrationBuilder.Sql(GetEmbeddedResource("Sql.CreateMaintenanceSchema.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Sql.Temporal_GetBaseHistoryTableDefinition.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Sql.Temporal_AddHistoryTables.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Sql.Temporal_GetMetadataFromInfoSchema.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Sql.Temporal_GetMetadataFromExtProp.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Sql.Temporal_UpdateExtendedProperties.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Sql.Temporal_DisableSystemTime.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Sql.Temporal_EnableSystemTime.sql"));

            migrationBuilder.Operations.Add(
                new CreateSqlServerTemporalTablesOperation());
            return migrationBuilder;
        }


        /// <summary>
        /// Creates SQL Server temporal tables and supporting maintenance objects
        /// </summary>
        /// <param name="migrationBuilder"></param>
        /// <returns></returns>
        public static MigrationBuilder DropSqlServerTemporalTables(this MigrationBuilder migrationBuilder) {

            migrationBuilder.Sql(GetEmbeddedResource("Sql.Temporal_AddHistoryTables_Drop.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Sql.Temporal_DisableSystemTime_Drop.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Sql.Temporal_EnableSystemTime_Drop.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Sql.Temporal_UpdateExtendedProperties_Drop.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Sql.Temporal_GetMetadataFromInfoSchema_Drop.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Sql.Temporal_GetMetadataFromExtProp_Drop.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Sql.Temporal_GetBaseHistoryTableDefinition_Drop.sql"));

            return migrationBuilder;
        }


        /// <summary>
        /// Creates all stored procedures used to maintain temporal tables.  This
        /// method should be called by the intital migration's Up() method
        /// </summary>
        /// <param name="migrationBuilder">The MigrationBuilder to extend</param>
        /// <returns>the MigrationBuilder (fluent API)</returns>
        public static MigrationBuilder CreateMaintenanceProcedures(
            this MigrationBuilder migrationBuilder,
            params Procedure[] specificProceduresToInclude) {

            migrationBuilder.Sql(GetEmbeddedResource("Sql.CreateMaintenanceSchema.sql"));

            if (specificProceduresToInclude.Length == 0) {
                migrationBuilder.Sql(GetEmbeddedResource("Sql.ResetIdentities.sql"));
                migrationBuilder.Sql(GetEmbeddedResource("Sql.ResetSequences.sql"));
                migrationBuilder.Sql(GetEmbeddedResource("Sql.GetMappings.sql"));
                migrationBuilder.Sql(GetEmbeddedResource("Sql.MaxDateTime2.sql"));
                migrationBuilder.Sql(GetEmbeddedResource("Sql.RightBefore.sql"));
                migrationBuilder.Sql(GetEmbeddedResource("Sql.RightAfter.sql"));
                migrationBuilder.Sql(GetEmbeddedResource("Sql.CloneAsGlobalTempTable.sql"));
            } else {
                foreach (var procedure in specificProceduresToInclude) {
                    migrationBuilder.Sql(GetEmbeddedResource(procedure.ToString() + ".sql"));
                    migrationBuilder.Sql(GetEmbeddedResource(procedure.ToString() + "_Drop.sql"));
                }
            }

            return migrationBuilder;
        }


        /// <summary>
        /// Adds support for a TestJson table, including the table itself, as well
        /// as a stored procedure for adding/updating (merging) records to the table.
        /// </summary>
        /// <param name="migrationBuilder">The MigrationBuilder to extend</param>
        /// <returns>the MigrationBuilder (fluent API)</returns>
        public static MigrationBuilder CreateTestJsonTableSupport(
    this MigrationBuilder migrationBuilder) {

            migrationBuilder.Sql(GetEmbeddedResource("Sql.CreateMaintenanceSchema.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Sql.CreateTestJsonTable.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Sql.SaveTestJson.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Sql.GetTestJson.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Sql.TruncateTestJson.sql"));
            return migrationBuilder;
        }


        /// <summary>
        /// Drops all stored procedures used to maintain temporal tables.  This
        /// method should be called by the intital migration's Down() method
        /// </summary>
        /// <param name="migrationBuilder">The MigrationBuilder to extend</param>
        /// <returns>the MigrationBuilder (fluent API)</returns>
        public static MigrationBuilder DropMaintenanceProcedures(
            this MigrationBuilder migrationBuilder) {

            migrationBuilder.Sql(GetEmbeddedResource("Sql.ResetSequences_Drop.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Sql.ResetIdentities_Drop.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Sql.GetMappings_Drop.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Sql.MaxDateTime2_Drop.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Sql.RightBefore_Drop.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Sql.RightAfter_Drop.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Sql.CloneAsGlobalTempTable_Drop.sql"));

            return migrationBuilder;
        }


        /// <summary>
        /// Removes support for a TestJson table, including the table itself, as well
        /// as a stored procedure for adding/updating (merging) records to the table.
        /// </summary>
        /// <param name="migrationBuilder">The MigrationBuilder to extend</param>
        /// <returns>the MigrationBuilder (fluent API)</returns>
        public static MigrationBuilder DropTestJsonTableSupport(
            this MigrationBuilder migrationBuilder) {

            migrationBuilder.Sql(GetEmbeddedResource("Sql.CreateMaintenanceSchema_Drop.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Sql.CreateTestJsonTable_Drop.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Sql.SaveTestJson_Drop.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Sql.GetTestJson_Drop.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Sql.TruncateTestJson_Drop.sql"));
            return migrationBuilder;
        }


        /// <summary>
        /// Adds history tables.  This method is called by the TemporalMigrationSqlGenerator
        /// </summary>
        /// <param name="migrationBuilder">The MigrationBuilder to extend</param>
        /// <returns>the MigrationBuilder (fluent API)</returns>
        public static MigrationBuilder AddHistoryTables(
            this MigrationBuilder migrationBuilder) {

            migrationBuilder.Sql("exec _.Temporal_AddHistoryTables;");
            migrationBuilder.Sql("exec _.Temporal_UpdateExtendedProperties;");

            return migrationBuilder;
        }


        /// <summary>
        /// Loads data from SQL Server a file containing semicolon-terminated INSERT statements
        /// </summary>
        /// <param name="migrationBuilder">The MigrationBuilder to extend</param>
        /// <param name="sqlFilePath">File containing INSERT statements, each terminated by ";"</param>
        /// <returns>the MigrationBuilder (fluent API)</returns>
        public static MigrationBuilder DoTemporalInserts(
            this MigrationBuilder migrationBuilder, string sqlFilePath) {

            migrationBuilder.Sql("exec _.Temporal_UpdateExtendedProperties;");
            migrationBuilder.Sql("exec _.Temporal_DisableSystemTime;");

            //load INSERT file and add to migrationBuilder
            string statements = File.ReadAllText(sqlFilePath);
            migrationBuilder.Sql(statements);

            migrationBuilder.Sql("exec _.Temporal_EnableSystemTime;");
            migrationBuilder.Sql("exec _.ResetIdentities;");
            migrationBuilder.Sql("exec _.ResetSequences;");

            return migrationBuilder;
        }


        /// <summary>
        /// Reads in a stored procedure definition, which has been stored as
        /// embedded resources so that it can be distributed with the NuGet assembly
        /// </summary>
        /// <param name="fileName">The name of the file to read in</param>
        /// <returns>The string contents of the file.</returns>
        private static string GetEmbeddedResource(string fileName) {
            var assembly = Assembly.GetExecutingAssembly();
            var resourceName = $"EDennis.MigrationsExtensions.{fileName}";

            using Stream stream = assembly.GetManifestResourceStream(resourceName);
            using StreamReader reader = new StreamReader(stream);
            string result = reader.ReadToEnd();
            return result;
        }

    }
}
