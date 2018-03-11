using Microsoft.EntityFrameworkCore.Migrations;
using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using System.Text;

namespace EDennis.MigrationsExtensions {
    public static class MigrationsExtensions {
        public static MigrationBuilder CreateMaintenanceProcedures(
            this MigrationBuilder migrationBuilder) {

            migrationBuilder.Sql(GetEmbeddedResource("Temporal_CreateMaintenanceSchema.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Temporal_AddHistoryTables.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Temporal_GetMetadataFromInfoSchema.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Temporal_GetMetadataFromExtProp.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Temporal_UpdateExtendedProperties.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Temporal_DisableSystemTime.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Temporal_EnableSystemTime.sql"));

            return migrationBuilder;
        }

        public static MigrationBuilder DropMaintenanceProcedures(
            this MigrationBuilder migrationBuilder) {

            migrationBuilder.Sql(GetEmbeddedResource("Temporal_AddHistoryTables_Drop.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Temporal_DisableSystemTime_Drop.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Temporal_EnableSystemTime_Drop.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Temporal_UpdateExtendedProperties_Drop.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Temporal_GetMetadataFromInfoSchema_Drop.sql"));
            migrationBuilder.Sql(GetEmbeddedResource("Temporal_GetMetadataFromExtProp_Drop.sql"));

            return migrationBuilder;
        }

        public static MigrationBuilder AddHistoryTables(
            this MigrationBuilder migrationBuilder) {

            migrationBuilder.Sql("exec _maintenance.Temporal_AddHistoryTables");
            migrationBuilder.Sql("exec _maintenance.Temporal_UpdateExtendedProperties");

            return migrationBuilder;
        }


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
