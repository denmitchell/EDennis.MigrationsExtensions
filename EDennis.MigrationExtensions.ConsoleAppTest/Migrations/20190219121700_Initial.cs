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

            migrationBuilder.CreateSequence<int>(
                name: "seqAddress");

            migrationBuilder.CreateSequence<int>(
                name: "seqPerson");

            migrationBuilder.CreateTable(
                name: "Person",
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
                columns: table => new
                {
                    PersonId = table.Column<int>(nullable: false),
                    AddressId = table.Column<int>(nullable: false, defaultValueSql: "next value for seqPerson"),
                    Street = table.Column<string>(maxLength: 90, nullable: true),
                    SysUserId = table.Column<int>(nullable: false, defaultValueSql: "((0))"),
                    SysStart = table.Column<DateTime>(nullable: false, defaultValueSql: "(getdate())"),
                    SysEnd = table.Column<DateTime>(nullable: false, defaultValueSql: "(CONVERT(datetime2, '9999-12-31 23:59:59.9999999'))")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Address", x => new { x.PersonId, x.AddressId });
                    table.ForeignKey(
                        name: "FK_Address_Person",
                        column: x => x.PersonId,
                        principalTable: "Person",
                        principalColumn: "PersonId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.SaveMappings();
            migrationBuilder.DoInserts("MigrationsInserts\\Initial_Insert.sql");

        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Address");

            migrationBuilder.DropTable(
                name: "Person");

            migrationBuilder.DropSequence(
                name: "seqAddress");

            migrationBuilder.DropSequence(
                name: "seqPerson");

            migrationBuilder.DropMaintenanceProcedures();
            migrationBuilder.DropTestJsonTableSupport();

        }
    }
}
