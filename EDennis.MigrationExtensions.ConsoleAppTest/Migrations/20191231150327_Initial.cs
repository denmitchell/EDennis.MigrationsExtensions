using System;
using EDennis.MigrationsExtensions;
using Microsoft.EntityFrameworkCore.Migrations;

namespace EDennis.MigrationExtensions.ConsoleAppTest.Migrations
{
    public partial class Initial : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateMaintenanceProcedures();
            migrationBuilder.CreateTestJsonTableSupport();
            
            migrationBuilder.EnsureSchema(
                name: "xxx");

            migrationBuilder.CreateSequence<int>(
                name: "seqAddress");

            migrationBuilder.CreateSequence<int>(
                name: "seqPerson");

            migrationBuilder.CreateTable(
                name: "Person",
                schema: "xxx",
                columns: table => new
                {
                    Id = table.Column<int>(nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    SysUser = table.Column<string>(nullable: true),
                    SysStart = table.Column<DateTime>(nullable: false, defaultValueSql: "(getdate())"),
                    SysEnd = table.Column<DateTime>(nullable: false, defaultValueSql: "(CONVERT(datetime2, '9999-12-31 23:59:59.9999999'))"),
                    Filter = table.Column<string>(nullable: true, defaultValueSql: "HOST_NAME()"),
                    FirstName = table.Column<string>(maxLength: 20, nullable: true),
                    DateOfBirth = table.Column<DateTime>(type: "date", nullable: false),
                    Weight = table.Column<decimal>(type: "decimal(10,3)", nullable: false),
                    PersonId = table.Column<Guid>(nullable: false, defaultValueSql: "newsequentialid()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Person", x => x.Id);
                    table.UniqueConstraint("AK_Person_PersonId", x => x.PersonId);
                });

            migrationBuilder.CreateTable(
                name: "Address",
                schema: "xxx",
                columns: table => new
                {
                    Id = table.Column<int>(nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    SysUser = table.Column<string>(nullable: true),
                    SysStart = table.Column<DateTime>(nullable: false, defaultValueSql: "(getdate())"),
                    SysEnd = table.Column<DateTime>(nullable: false, defaultValueSql: "(CONVERT(datetime2, '9999-12-31 23:59:59.9999999'))"),
                    Filter = table.Column<string>(nullable: true, defaultValueSql: "HOST_NAME()"),
                    Street = table.Column<string>(maxLength: 90, nullable: true),
                    PersonId = table.Column<Guid>(nullable: false),
                    AddressId = table.Column<Guid>(nullable: false, defaultValueSql: "newsequentialid()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Address", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Address_Person",
                        column: x => x.PersonId,
                        principalSchema: "xxx",
                        principalTable: "Person",
                        principalColumn: "PersonId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Address_PersonId",
                schema: "xxx",
                table: "Address",
                column: "PersonId");

            migrationBuilder.CreateSqlServerTemporalTables();
            migrationBuilder.SaveMappings();

        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Address",
                schema: "xxx");

            migrationBuilder.DropTable(
                name: "Person",
                schema: "xxx");

            migrationBuilder.DropSequence(
                name: "seqAddress");

            migrationBuilder.DropSequence(
                name: "seqPerson");
        }
    }
}
