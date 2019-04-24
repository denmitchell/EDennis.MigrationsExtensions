using System;
using Microsoft.EntityFrameworkCore.Migrations;
using EDennis.MigrationsExtensions;

namespace EDennis.MigrationExtensions.ConsoleAppTest.Migrations
{
    public partial class Initial : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {

            migrationBuilder.CreateMaintenanceProcedures();

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
                    PersonId = table.Column<int>(nullable: false, defaultValueSql: "next value for seqPerson"),
                    FirstName = table.Column<string>(maxLength: 20, nullable: true),
                    DateOfBirth = table.Column<DateTime>(type: "date", nullable: false),
                    Weight = table.Column<decimal>(type: "decimal(10,3)", nullable: false),
                    SysUserId = table.Column<int>(nullable: false, defaultValueSql: "((0))"),
                    SysStart = table.Column<DateTime>(nullable: false, defaultValueSql: "(getdate())"),
                    SysEnd = table.Column<DateTime>(nullable: false, defaultValueSql: "(CONVERT(datetime2, '9999-12-31 23:59:59.9999999'))")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Person", x => x.PersonId);
                });

            migrationBuilder.CreateTable(
                name: "Address",
                schema: "xxx",
                columns: table => new
                {
                    PersonId = table.Column<int>(nullable: false),
                    AddressId = table.Column<int>(nullable: false, defaultValueSql: "next value for seqPerson"),
                    Street = table.Column<string>(maxLength: 90, nullable: true),
                    SysUserId = table.Column<int>(nullable: false, defaultValueSql: "((0))"),
                    SysStart = table.Column<DateTime>(nullable: false, defaultValueSql: "(getdate())"),
                    SysEnd = table.Column<DateTime>(nullable: false, defaultValueSql: "(CONVERT(datetime2, '9999-12-31 23:59:59.9999999'))"),
                    PersonId1 = table.Column<int>(nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Address", x => new { x.PersonId, x.AddressId });
                    table.ForeignKey(
                        name: "FK_Address_Person_PersonId1",
                        column: x => x.PersonId1,
                        principalSchema: "xxx",
                        principalTable: "Person",
                        principalColumn: "PersonId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Address_PersonId1",
                schema: "xxx",
                table: "Address",
                column: "PersonId1");

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
