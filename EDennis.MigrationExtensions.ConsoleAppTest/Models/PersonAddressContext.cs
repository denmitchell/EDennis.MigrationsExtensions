using EDennis.MigrationsExtensions;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Migrations;

namespace EDennis.MigrationExtensions.ConsoleAppTest {
    public class PersonAddressContext : DbContext {

        public DbSet<Person> Persons { get; set; }
        public DbSet<Address> Addresses { get; set; }


        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder) {
            optionsBuilder.UseSqlServer("Server=(localdb)\\mssqllocaldb;Database=PersonAddress01;Trusted_Connection=True;MultipleActiveResultSets=true")
                .ReplaceService<IMigrationsSqlGenerator, MigrationsExtensionsSqlGenerator>();
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder) {

            modelBuilder.HasSequence<int>("seqPerson").StartsAt(1);
            modelBuilder.HasSequence<int>("seqAddress").StartsAt(1);

            modelBuilder.Entity<Person>(e => {

                e.HasAnnotation("SystemVersioned", true);

                e.ToTable("Person", "xxx")
                   .HasKey(p => p.Id);

                e.Property(p => p.PersonId)
                    .HasDefaultValueSql("newsequentialid()");
                e.Property(p => p.Filter)
                    .HasDefaultValueSql("HOST_NAME()");

                e.Property(p => p.SysStart)
                    .ValueGeneratedOnAddOrUpdate();
                e.Property(p => p.SysEnd)
                    .ValueGeneratedOnAddOrUpdate();

            });



            modelBuilder.Entity<Address>(e => {
                e.HasAnnotation("SystemVersioned", true);

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
                e.Property(p => p.Filter)
                    .HasDefaultValueSql("HOST_NAME()");

                e.Property(a => a.SysStart)
                    .ValueGeneratedOnAddOrUpdate();
                e.Property(a => a.SysEnd)
                    .ValueGeneratedOnAddOrUpdate();
            });



            //modelBuilder.DropForeignKeys();

        }

    }
}
