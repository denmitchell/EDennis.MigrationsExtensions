using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;
using Microsoft.EntityFrameworkCore.Migrations.Operations;
using System;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Runtime.Serialization.Json;
using System.Text.RegularExpressions;
using System.Text.Json;
using System.Collections.Generic;
using System.Text;

namespace EDennis.MigrationsExtensions {
    public class MigrationsExtensionsSqlGenerator : SqlServerMigrationsSqlGenerator {


        public MigrationsExtensionsSqlGenerator(
            MigrationsSqlGeneratorDependencies dependencies,
            IMigrationsAnnotationProvider migrationsAnnotations) 
            : base(dependencies, migrationsAnnotations) {

            _dependencies = dependencies;
            _migrationsAnnotations = migrationsAnnotations;
        }

        private readonly MigrationsSqlGeneratorDependencies _dependencies;
        private readonly IMigrationsAnnotationProvider _migrationsAnnotations;

        private SqlServerMigrationsSqlGenerator _internalGenerator;



        protected override void Generate(MigrationOperation operation,
            IModel model, MigrationCommandListBuilder builder) {

            var sqlHelper = Dependencies.SqlGenerationHelper;

            Debugger.Launch();

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
                    bool systemVersioned = (bool)Convert.ChangeType(
                        model.GetEntityTypes()
                        .FirstOrDefault(e=>e.GetTableName()==opT.Name)
                        ?.FindAnnotation("SystemVersioned")
                        ?.Value
                        ?? false, typeof(bool));

                    if (systemVersioned) {

                        _internalGenerator = new SqlServerMigrationsSqlGenerator(_dependencies, _migrationsAnnotations);
                        var commands = _internalGenerator.Generate(new List<MigrationOperation> { operation }, model);
                        var commandText = commands.FirstOrDefault().CommandText;
                        string[] commandLines = commandText.Split(new[] { Environment.NewLine }, StringSplitOptions.None);

                        var sb = new StringBuilder();
                        var colDefs = new List<string>();
                        
                        foreach (var line in commandLines) {
                            if (line.TrimStart().StartsWith("[SysStart] datetime2")) {
                                sb.Append("    [SysStart] datetime2 GENERATED ALWAYS AS ROW START");
                                if (line.EndsWith(","))
                                    sb.Append(",");
                                sb.AppendLine();
                            } else if (line.TrimStart().StartsWith("[SysEnd] datetime2")) {
                                sb.AppendLine("    [SysEnd] datetime2 GENERATED ALWAYS AS ROW END,");
                                sb.Append("    PERIOD FOR SYSTEM_TIME (SysStart, SysEnd)");
                                if (line.EndsWith(","))
                                    sb.Append(",");
                                sb.AppendLine();
                            } else if (line.TrimStart().StartsWith(");")) {
                                sb.AppendLine(")");
                                sb.AppendLine($"WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = {opT.Schema}_history.{opT.Name}));");
                            } else
                                sb.AppendLine(line);
                        }

                        var opS = new SqlOperation {
                            Sql = sb.ToString()
                        };

                        Debug.WriteLine(opS.Sql);

                        var opS2 = new SqlOperation {
                            Sql = $"IF NOT EXISTS(SELECT * from sys.schemas WHERE name = '{opT.Schema}_history') CREATE SCHEMA {opT.Schema}_history;"
                        };

                        base.Generate(opS2, model, builder);
                        base.Generate(opS, model, builder);

                    } else {
                        base.Generate(operation, model, builder);
                    }
                    System.Diagnostics.Debug.WriteLine($"Staging SQL for CREATE TABLE {opT.Name} ...");
                }
                if (operation is SqlOperation) {
                    var opS = operation as SqlOperation;
                    System.Diagnostics.Debug.WriteLine($"Staging SQL for {GetSqlSnippet(opS)}");
                    base.Generate(operation, model, builder);
                }
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
