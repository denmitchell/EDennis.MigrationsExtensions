﻿// <auto-generated />
using System;
using EDennis.MigrationExtensions.ConsoleAppTest;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;

namespace EDennis.MigrationExtensions.ConsoleAppTest.Migrations
{
    [DbContext(typeof(PersonAddressContext))]
    partial class PersonAddressContextModelSnapshot : ModelSnapshot
    {
        protected override void BuildModel(ModelBuilder modelBuilder)
        {
#pragma warning disable 612, 618
            modelBuilder
                .HasAnnotation("ProductVersion", "3.1.5")
                .HasAnnotation("Relational:MaxIdentifierLength", 128)
                .HasAnnotation("Relational:Sequence:.seqAddress", "'seqAddress', '', '1', '1', '', '', 'Int32', 'False'")
                .HasAnnotation("Relational:Sequence:.seqPerson", "'seqPerson', '', '1', '1', '', '', 'Int32', 'False'")
                .HasAnnotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn);

            modelBuilder.Entity("EDennis.MigrationExtensions.ConsoleAppTest.Address", b =>
                {
                    b.Property<int>("Id")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("int")
                        .HasAnnotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn);

                    b.Property<Guid>("AddressId")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("uniqueidentifier")
                        .HasDefaultValueSql("newsequentialid()");

                    b.Property<string>("Filter")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("nvarchar(max)")
                        .HasDefaultValueSql("HOST_NAME()");

                    b.Property<Guid>("PersonId")
                        .HasColumnType("uniqueidentifier");

                    b.Property<string>("Street")
                        .HasColumnType("nvarchar(90)")
                        .HasMaxLength(90);

                    b.Property<DateTime>("SysEnd")
                        .ValueGeneratedOnAddOrUpdate()
                        .HasColumnType("datetime2")
                        .HasDefaultValueSql("(CONVERT(datetime2, '9999-12-31 23:59:59.9999999'))");

                    b.Property<DateTime>("SysStart")
                        .ValueGeneratedOnAddOrUpdate()
                        .HasColumnType("datetime2")
                        .HasDefaultValueSql("(getdate())");

                    b.Property<string>("SysUser")
                        .HasColumnType("nvarchar(max)");

                    b.HasKey("Id");

                    b.HasIndex("PersonId");

                    b.ToTable("Address","xxx");
                });

            modelBuilder.Entity("EDennis.MigrationExtensions.ConsoleAppTest.Person", b =>
                {
                    b.Property<int>("Id")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("int")
                        .HasAnnotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn);

                    b.Property<DateTime>("DateOfBirth")
                        .HasColumnType("date");

                    b.Property<string>("Filter")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("nvarchar(max)")
                        .HasDefaultValueSql("HOST_NAME()");

                    b.Property<string>("FirstName")
                        .HasColumnType("nvarchar(20)")
                        .HasMaxLength(20);

                    b.Property<Guid>("PersonId")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("uniqueidentifier")
                        .HasDefaultValueSql("newsequentialid()");

                    b.Property<DateTime>("SysEnd")
                        .ValueGeneratedOnAddOrUpdate()
                        .HasColumnType("datetime2")
                        .HasDefaultValueSql("(CONVERT(datetime2, '9999-12-31 23:59:59.9999999'))");

                    b.Property<DateTime>("SysStart")
                        .ValueGeneratedOnAddOrUpdate()
                        .HasColumnType("datetime2")
                        .HasDefaultValueSql("(getdate())");

                    b.Property<string>("SysUser")
                        .HasColumnType("nvarchar(max)");

                    b.Property<decimal>("Weight")
                        .HasColumnType("decimal(10,3)");

                    b.HasKey("Id");

                    b.ToTable("Person","xxx");

                    b.HasAnnotation("SystemVersioned", true);
                });

            modelBuilder.Entity("EDennis.MigrationExtensions.ConsoleAppTest.Address", b =>
                {
                    b.HasOne("EDennis.MigrationExtensions.ConsoleAppTest.Person", "Person")
                        .WithMany("Addresses")
                        .HasForeignKey("PersonId")
                        .HasConstraintName("FK_Address_Person")
                        .HasPrincipalKey("PersonId")
                        .OnDelete(DeleteBehavior.ClientCascade)
                        .IsRequired();
                });
#pragma warning restore 612, 618
        }
    }
}
