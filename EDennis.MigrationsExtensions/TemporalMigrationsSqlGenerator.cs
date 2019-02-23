using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;
using Microsoft.EntityFrameworkCore.Migrations.Operations;
using System.Linq;

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


            if (operation is CreateTableOperation op ) {                    
                base.Generate(operation, model, builder);
                if (op.Name == "__EFMigrationsHistory")
                    return;
                builder.Append("EXEC _maintenance.Temporal_AddHistoryTables");
                builder.AppendLine(sqlHelper.StatementTerminator);
                builder.Append("EXEC _maintenance.Temporal_UpdateExtendedProperties");
                builder.AppendLine(sqlHelper.StatementTerminator);
                builder.EndCommand();
            } else if (operation is SaveMappingsOperation) {

                var entityTypes = model.GetEntityTypes();

                foreach (var entityType in entityTypes) {
                    var nn = entityType.Name.Split(".").ToList();
                    var className = nn.Last();
                    nn.Remove(nn.Last());
                    var namespaceName = string.Join('.', nn);

                    var mapping = entityType.Relational();
                    var schema = mapping.Schema ?? "dbo";
                    var tableName = mapping.TableName;

                    var sql = $"execute sp_addextendedproperty " +
                        $"@name = N'efcore:{namespaceName}', @value = N'{className}', " +
                        $"@level0type = N'SCHEMA', @level0name = N'{schema}', " +
                        $"@level1type = N'TABLE', @level1name = N'{tableName}'";

                    builder.Append(sql);
                    builder.AppendLine(sqlHelper.StatementTerminator);

                    var navProps = entityType.GetNavigations().Select(x => x.Name);

                    foreach (var prop in entityType.GetProperties()) {
                        if (navProps.Contains(prop.Name))
                            continue;
                        var colMapping = prop.Relational();
                        var columnName = colMapping.ColumnName;

                        var sqlCol = $"execute sp_addextendedproperty " +
                            $"@name = N'efcore:{namespaceName}', @value = N'{className}.{prop.Name}', " +
                            $"@level0type = N'SCHEMA', @level0name = N'{schema}', " +
                            $"@level1type = N'TABLE', @level1name = N'{tableName}', " +
                            $"@level2type = N'COLUMN', @level2name = N'{columnName}'";

                        builder.Append(sqlCol);
                        builder.AppendLine(sqlHelper.StatementTerminator);
                    }

                }
                builder.EndCommand();
            } else {
                base.Generate(operation, model, builder);
            }
        }


    }
}
