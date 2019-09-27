using System;

namespace EDennis.MigrationExtensions.ConsoleAppTest
{
    public class Address : BaseEntity {
        public string Street { get; set; }

        public Guid PersonId { get; set; }
        public Guid AddressId { get; set; }
        public Person Person { get; set; }
    }
}