﻿// <auto-generated />
using CodeFirstPractice;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;
using Microsoft.EntityFrameworkCore.Storage;
using Microsoft.EntityFrameworkCore.Storage.Internal;
using System;

namespace EDennis.MigrationExtensions.ConsoleAppTest.Migrations
{
    [DbContext(typeof(PersonAddressContext))]
    partial class PersonAddressContextModelSnapshot : ModelSnapshot
    {
        protected override void BuildModel(ModelBuilder modelBuilder)
        {
#pragma warning disable 612, 618
            modelBuilder
                .HasAnnotation("ProductVersion", "2.0.1-rtm-125")
                .HasAnnotation("Relational:Sequence:.seqAddress", "'seqAddress', '', '1', '1', '', '', 'Int32', 'False'")
                .HasAnnotation("Relational:Sequence:.seqPerson", "'seqPerson', '', '1', '1', '', '', 'Int32', 'False'")
                .HasAnnotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn);

            modelBuilder.Entity("CodeFirstPractice.Address", b =>
                {
                    b.Property<int>("PersonId");

                    b.Property<int>("AddressId")
                        .ValueGeneratedOnAdd()
                        .HasDefaultValueSql("next value for seqPerson");

                    b.Property<string>("Street")
                        .HasMaxLength(90);

                    b.Property<DateTime>("SysEnd")
                        .ValueGeneratedOnAddOrUpdate()
                        .HasDefaultValueSql("(CONVERT(datetime2, '9999-12-31 23:59:59.9999999'))");

                    b.Property<DateTime>("SysStart")
                        .ValueGeneratedOnAddOrUpdate()
                        .HasDefaultValueSql("(getdate())");

                    b.Property<int>("SysUserId")
                        .ValueGeneratedOnAdd()
                        .HasDefaultValueSql("((0))");

                    b.HasKey("PersonId", "AddressId");

                    b.ToTable("Address");
                });

            modelBuilder.Entity("CodeFirstPractice.Person", b =>
                {
                    b.Property<int>("PersonId")
                        .ValueGeneratedOnAdd()
                        .HasDefaultValueSql("next value for seqPerson");

                    b.Property<DateTime>("DateOfBirth")
                        .HasColumnType("date");

                    b.Property<string>("FirstName")
                        .HasMaxLength(20);

                    b.Property<DateTime>("SysEnd")
                        .ValueGeneratedOnAddOrUpdate()
                        .HasDefaultValueSql("(CONVERT(datetime2, '9999-12-31 23:59:59.9999999'))");

                    b.Property<DateTime>("SysStart")
                        .ValueGeneratedOnAddOrUpdate()
                        .HasDefaultValueSql("(getdate())");

                    b.Property<int>("SysUserId")
                        .ValueGeneratedOnAdd()
                        .HasDefaultValueSql("((0))");

                    b.Property<decimal>("Weight")
                        .HasColumnType("decimal(10,3)");

                    b.HasKey("PersonId");

                    b.ToTable("Person");
                });

            modelBuilder.Entity("CodeFirstPractice.Address", b =>
                {
                    b.HasOne("CodeFirstPractice.Person", "Person")
                        .WithMany("Addresses")
                        .HasForeignKey("PersonId")
                        .HasConstraintName("FK_Address_Person")
                        .OnDelete(DeleteBehavior.Restrict);
                });
#pragma warning restore 612, 618
        }
    }
}
