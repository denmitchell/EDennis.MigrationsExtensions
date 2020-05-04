using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;
using Microsoft.EntityFrameworkCore.Migrations.Operations;
using System;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;

namespace EDennis.MigrationsExtensions {
    public class MigrationsExtensionsSqlGenerator : SqlServerMigrationsSqlGenerator {


        public MigrationsExtensionsSqlGenerator(
            MigrationsSqlGeneratorDependencies dependencies,
            IMigrationsAnnotationProvider migrationsAnnotations) 
            : base(dependencies, migrationsAnnotations) {
        }


        protected override void Generate(MigrationOperation operation,
            IModel model, MigrationCommandListBuilder builder) {

            var sqlHelper = Dependencies.SqlGenerationHelper;

            if (operation is CreateSqlServerTemporalTablesOperation op ) {                    
                builder.Append("EXEC _.Temporal_AddHistoryTables");
                builder.AppendLine(sqlHelper.StatementTerminator);
                builder.Append("EXEC _.Temporal_UpdateExtendedProperties");
                builder.AppendLine(sqlHelper.StatementTerminator);
                builder.EndCommand();
            } else if (operation is SaveMappingsOperation) {

                var entityTypes = model.GetEntityTypes();

                foreach (var entityType in entityTypes) {
                    var nn = entityType.Name.Split('.').ToList();
                    var className = nn.Last();
                    nn.Remove(nn.Last());
                    var namespaceName = string.Join(".", nn);
                    
                    //var mapping = entityType.Relational();
                    var schema = entityType.GetSchema() ?? "dbo";
                    var tableName = entityType.GetTableName();// mapping.TableName;

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
                        //var colMapping = prop.Relational();
                        var columnName = prop.GetColumnName();// colMapping.ColumnName;

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
                if (operation is CreateTableOperation) {
                    var opT = operation as CreateTableOperation;
                    System.Diagnostics.Debug.WriteLine($"Staging SQL for CREATE TABLE {opT.Name} ...");
                }
                if (operation is SqlOperation) {
                    var opS = operation as SqlOperation;
                    System.Diagnostics.Debug.WriteLine($"Staging SQL for {GetSqlSnippet(opS)}");
                }
                base.Generate(operation, model, builder);
            }
        }

        static Regex sqlRegex = new Regex("^\\s*(CREATE|create|INSERT|insert|ALTER|alter|DELETE|delete|UPDATE|update)([A-Za-z0-9_ \\[\\]\\.])+",RegexOptions.IgnoreCase | RegexOptions.Multiline | RegexOptions.Compiled);

        static string GetSqlSnippet(SqlOperation op) {
            if(sqlRegex.IsMatch(op.Sql)) 
                return sqlRegex.Match(op.Sql).Value;
            else
                return op.Sql.Substring(0, Math.Min(op.Sql.Length, 500) - 1);
        }

    }
}
