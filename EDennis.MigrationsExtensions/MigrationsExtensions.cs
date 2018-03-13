using Microsoft.EntityFrameworkCore.Migrations;
using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using System.Text;

namespace EDennis.MigrationsExtensions {

    /// <summary>
    /// These extensions to MigrationBuilder facilitate working with SQL Server 
    /// temporal tables.
    /// </summary>
    public static class MigrationsExtensions {

        /// <summary>
        /// Creates all stored procedures used to maintain temporal tables.  This
        /// method should be called by the intital migration's Up() method
        /// </summary>
        /// <param name="migrationBuilder">The MigrationBuilder to extend</param>
        /// <returns>the MigrationBuilder (fluent API)</returns>
        public static MigrationBuilder CreateMaintenanceProcedures(
            this MigrationBuilder migrationBuilder) {

            migrationBuilder.Sql(GetEmbeddedResource("Temporal_CreateMaintenanceSchema.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Temporal_AddHistoryTables.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Temporal_GetMetadataFromInfoSchema.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Temporal_GetMetadataFromExtProp.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Temporal_UpdateExtendedProperties.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Temporal_DisableSystemTime.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Temporal_EnableSystemTime.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("ResetSequences.sql"));

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

            migrationBuilder.Sql(GetEmbeddedResource("ResetSequences_Drop.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Temporal_AddHistoryTables_Drop.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Temporal_DisableSystemTime_Drop.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Temporal_EnableSystemTime_Drop.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Temporal_UpdateExtendedProperties_Drop.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Temporal_GetMetadataFromInfoSchema_Drop.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Temporal_GetMetadataFromExtProp_Drop.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Temporal_CreateMaintenanceSchema_Drop.sql"));

            return migrationBuilder;
        }

        /// <summary>
        /// Adds history tables.  This method is called by the TemporalMigrationSqlGenerator
        /// </summary>
        /// <param name="migrationBuilder">The MigrationBuilder to extend</param>
        /// <returns>the MigrationBuilder (fluent API)</returns>
        public static MigrationBuilder AddHistoryTables(
            this MigrationBuilder migrationBuilder) {

            migrationBuilder.Sql("exec _maintenance.Temporal_AddHistoryTables;");
            migrationBuilder.Sql("exec _maintenance.Temporal_UpdateExtendedProperties;");

            return migrationBuilder;
        }


        /// <summary>
        /// Loads data from SQL Server a file containing semicolon-terminated INSERT statements
        /// </summary>
        /// <param name="migrationBuilder">The MigrationBuilder to extend</param>
        /// <param name="sqlFilePath">File containing INSERT statements, each terminated by ";"</param>
        /// <returns>the MigrationBuilder (fluent API)</returns>
        public static MigrationBuilder DoInserts(
            this MigrationBuilder migrationBuilder, string sqlFilePath) {

            migrationBuilder.Sql("exec _maintenance.Temporal_UpdateExtendedProperties;");
            migrationBuilder.Sql("exec _maintenance.Temporal_DisableSystemTime;");

            //load INSERT file and add to migrationBuilder
            string statements = File.ReadAllText(sqlFilePath);
            migrationBuilder.Sql(statements);

            migrationBuilder.Sql("exec _maintenance.Temporal_EnableSystemTime;");
            migrationBuilder.Sql("exec _maintenance.ResetSequences;");

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

            var x = assembly.GetManifestResourceNames();

            using (Stream stream = assembly.GetManifestResourceStream(resourceName)) {
                using (StreamReader reader = new StreamReader(stream)) {
                    string result = reader.ReadToEnd();
                    return result;
                }
            }
        }

    }
}
