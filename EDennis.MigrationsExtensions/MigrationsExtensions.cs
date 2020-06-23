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
