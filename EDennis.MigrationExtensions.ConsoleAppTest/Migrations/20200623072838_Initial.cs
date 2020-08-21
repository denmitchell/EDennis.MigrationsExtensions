using System;
using Microsoft.EntityFrameworkCore.Migrations;
using System.IO;
using EDennis.MigrationsExtensions;

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
                    SysUser = table.Column<string>(maxLength: 255, nullable: true),
                    SysStart = table.Column<DateTime>(type: "datetime2", nullable: false),
                    SysEnd = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Filter = table.Column<string>(maxLength: 255, nullable: true, defaultValueSql: "HOST_NAME()"),
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
                    SysUser = table.Column<string>(maxLength: 255, nullable: true),
                    SysStart = table.Column<DateTime>(type: "datetime2", nullable: false),
                    SysEnd = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Filter = table.Column<string>(maxLength: 255, nullable: true, defaultValueSql: "HOST_NAME()"),
                    Street = table.Column<string>(maxLength: 150, nullable: true),
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
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Address_PersonId",
                schema: "xxx",
                table: "Address",
                column: "PersonId");

            migrationBuilder.SaveMappings();
            migrationBuilder.Sql(File.ReadAllText("MigrationsSql\\PostUp\\01_InsertPersons.sql"));
            migrationBuilder.Sql(File.ReadAllText("MigrationsSql\\PostUp\\02_InsertAddresses.sql"));

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
