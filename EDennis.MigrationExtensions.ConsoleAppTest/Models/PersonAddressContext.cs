using EDennis.MigrationsExtensions;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Migrations;
using System;
using System.Collections.Generic;
using System.Text;

namespace EDennis.MigrationExtensions.ConsoleAppTest
{
    public class PersonAddressContext : DbContext {

        public DbSet<Person> Persons { get; set; }
        public DbSet<Address> Addresses { get; set; }


        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder) {
            optionsBuilder.UseSqlServer("Data Source=(localdb)\\mssqllocaldb;Initial Catalog=PersonAddress01;Integrated Security=SSPI;")
                .ReplaceService<IMigrationsSqlGenerator, MigrationsExtensionsSqlGenerator>();
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder) {

            modelBuilder.HasSequence<int>("seqPerson").StartsAt(1);
            modelBuilder.HasSequence<int>("seqAddress").StartsAt(1);

            modelBuilder.Entity<Person>(e => {
                e.ToTable("Person", "xxx")
                   .HasKey(p => p.Id);

                e.Property(p => p.PersonId)
                    .HasDefaultValueSql("newsequentialid()");
                e.Property(p => p.FirstName)
                    .HasMaxLength(20);
                e.Property(p => p.DateOfBirth)
                    .HasColumnType("date");
                e.Property(p => p.Weight)
                    .HasColumnType("decimal(10,3)");
                e.Property(p => p.Filter)
                    .HasDefaultValueSql("HOST_NAME()");

                e.Property(p => p.SysStart)
                    .HasDefaultValueSql("(getdate())")
                    .ValueGeneratedOnAddOrUpdate();
                e.Property(p => p.SysEnd)
                    .HasDefaultValueSql("(CONVERT(datetime2, '9999-12-31 23:59:59.9999999'))")
                    .ValueGeneratedOnAddOrUpdate();

            });



            modelBuilder.Entity<Address>(e => { 
                e.ToTable("Address", "xxx")
                    .HasKey(a => a.Id);

                e.HasOne(a => a.Person)
                    .WithMany(p => p.Addresses)
                    .HasPrincipalKey(p => p.PersonId)
                    .HasForeignKey(a => a.PersonId)
                    .HasConstraintName("FK_Address_Person")
                    .OnDelete(DeleteBehavior.ClientCascade);

                e.Property(a => a.AddressId)
                    .HasDefaultValueSql("newsequentialid()");
                e.Property(a => a.Street)
                    .HasMaxLength(90);
                e.Property(p => p.Filter)
                    .HasDefaultValueSql("HOST_NAME()");

                e.Property(a => a.SysStart)
                    .HasDefaultValueSql("(getdate())")
                    .ValueGeneratedOnAddOrUpdate();
                e.Property(a => a.SysEnd)
                    .HasDefaultValueSql("(CONVERT(datetime2, '9999-12-31 23:59:59.9999999'))")
                    .ValueGeneratedOnAddOrUpdate();
            });



            //modelBuilder.DropForeignKeys();

        }

    }
}
