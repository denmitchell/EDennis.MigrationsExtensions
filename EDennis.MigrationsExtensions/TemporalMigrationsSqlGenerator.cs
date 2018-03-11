using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;
using Microsoft.EntityFrameworkCore.Migrations.Operations;

namespace EDennis.MigrationsExtensions {
    public class TemporalMigrationsSqlGenerator : SqlServerMigrationsSqlGenerator {


        public TemporalMigrationsSqlGenerator(
            MigrationsSqlGeneratorDependencies dependencies, 
            IMigrationsAnnotationProvider migrationsAnnotations) 
            : base(dependencies, migrationsAnnotations) {
        }


        protected override void Generate(MigrationOperation operation,
            IModel model, MigrationCommandListBuilder builder) {

            var sqlHelper = Dependencies.SqlGenerationHelper;

            base.Generate(operation, model, builder);

            bool is__EFMigrationsHistory = (builder.GetCommandList()[builder.GetCommandList().Count - 1]
                        .CommandText.Contains("__EFMigrationsHistory"));

            if (operation is CreateTableOperation && !is__EFMigrationsHistory) {
                builder.Append("EXEC _maintenance.Temporal_AddHistoryTables");
                builder.AppendLine(sqlHelper.StatementTerminator);
                builder.Append("EXEC _maintenance.Temporal_UpdateExtendedProperties");
                builder.AppendLine(sqlHelper.StatementTerminator);
                builder.EndCommand();
            }
        }

    }
}
