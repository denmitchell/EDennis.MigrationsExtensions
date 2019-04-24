using EDennis.MigrationsExtensions;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Migrations;
using System;
using System.Collections.Generic;
using System.Text;

namespace CodeFirstPractice {
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

            modelBuilder.Entity<Person>()
                .ToTable("Person","pers")
                .HasKey(p => p.PersonId);

            modelBuilder.Entity<Person>().Property(p => p.PersonId).HasDefaultValueSql("next value for seqPerson");
            modelBuilder.Entity<Person>().Property(p => p.FirstName).HasMaxLength(20);
            modelBuilder.Entity<Person>().Property(p => p.DateOfBirth).HasColumnType("date");
            modelBuilder.Entity<Person>().Property(p => p.Weight).HasColumnType("decimal(10,3)");
            modelBuilder.Entity<Person>().Property(p => p.SysUserId).HasDefaultValueSql("((0))");
            modelBuilder.Entity<Person>().Property(p => p.SysStart).HasDefaultValueSql("(getdate())").ValueGeneratedOnAddOrUpdate();
            modelBuilder.Entity<Person>().Property(p => p.SysEnd).HasDefaultValueSql("(CONVERT(datetime2, '9999-12-31 23:59:59.9999999'))").ValueGeneratedOnAddOrUpdate();


            modelBuilder.Entity<Address>()
                .ToTable("Address","addr")
                .HasKey(a => new { a.PersonId, a.AddressId });

            modelBuilder.Entity<Address>()
                .HasOne(a => a.Person)
                .WithMany(p => p.Addresses)
                .HasForeignKey(a => a.PersonId)
                .HasConstraintName("FK_Address_Person")
                .OnDelete(DeleteBehavior.Restrict);

            //modelBuilder.Entity<Address>()
            //    .DropForeignKeys();

            modelBuilder.Entity<Address>().Property(a => a.AddressId).HasDefaultValueSql("next value for seqPerson");
            modelBuilder.Entity<Address>().Property(a => a.Street).HasMaxLength(90);
            modelBuilder.Entity<Address>().Property(a => a.SysUserId).HasDefaultValueSql("((0))");
            modelBuilder.Entity<Address>().Property(a => a.SysStart).HasDefaultValueSql("(getdate())").ValueGeneratedOnAddOrUpdate();
            modelBuilder.Entity<Address>().Property(a => a.SysEnd).HasDefaultValueSql("(CONVERT(datetime2, '9999-12-31 23:59:59.9999999'))").ValueGeneratedOnAddOrUpdate();


            modelBuilder.DropForeignKeys();

        }

    }
}
