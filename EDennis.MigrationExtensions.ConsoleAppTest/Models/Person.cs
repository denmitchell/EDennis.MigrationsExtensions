using System;
using System.Collections.Generic;
using System.Text;

namespace EDennis.MigrationExtensions.ConsoleAppTest
{
    public class Person : BaseEntity {
        public string FirstName { get; set; }
        public DateTime DateOfBirth { get; set; }
        public decimal Weight { get; set; }

        public Guid PersonId { get; set; }
        public List<Address> Addresses { get; set; }
    }
}
