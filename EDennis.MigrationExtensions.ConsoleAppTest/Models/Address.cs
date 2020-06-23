using System;
using System.ComponentModel.DataAnnotations;

namespace EDennis.MigrationExtensions.ConsoleAppTest
{
    public class Address : BaseEntity {

        [MaxLength(150)]
        public string Street { get; set; }

        public Guid PersonId { get; set; }
        public Guid AddressId { get; set; }
        public Person Person { get; set; }
    }
}