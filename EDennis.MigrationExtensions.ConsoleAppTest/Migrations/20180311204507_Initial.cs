using EDennis.MigrationsExtensions;
using Microsoft.EntityFrameworkCore.Migrations;
using System;
using System.Collections.Generic;

namespace EDennis.MigrationExtensions.ConsoleAppTest.Migrations
{
    public partial class Initial : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateMaintenanceProcedures();

            migrationBuilder.CreateSequence<int>(
                name: "seqAddress");

            migrationBuilder.CreateSequence<int>(
                name: "seqPerson");

            migrationBuilder.CreateTable(
                name: "Person",
                columns: table => new
                {
                    PersonId = table.Column<int>(nullable: false, defaultValueSql: "next value for seqPerson"),
                    DateOfBirth = table.Column<DateTime>(type: "date", nullable: false),
                    FirstName = table.Column<string>(maxLength: 20, nullable: true),
                    SysEnd = table.Column<DateTime>(nullable: false, defaultValueSql: "(CONVERT(datetime2, '9999-12-31 23:59:59.9999999'))"),
                    SysStart = table.Column<DateTime>(nullable: false, defaultValueSql: "(getdate())"),
                    SysUserId = table.Column<int>(nullable: false, defaultValueSql: "((0))"),
                    Weight = table.Column<decimal>(type: "decimal(10,3)", nullable: false)
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
                    SysEnd = table.Column<DateTime>(nullable: false, defaultValueSql: "(CONVERT(datetime2, '9999-12-31 23:59:59.9999999'))"),
                    SysStart = table.Column<DateTime>(nullable: false, defaultValueSql: "(getdate())"),
                    SysUserId = table.Column<int>(nullable: false, defaultValueSql: "((0))")
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

            migrationBuilder.DoInserts("MigrationsInserts\\20180311204507_Insert.sql");

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
        }
    }
}
