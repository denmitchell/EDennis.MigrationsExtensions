using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace EDennis.MigrationExtensions.ConsoleAppTest {
    public class Person : BaseEntity {

        [MaxLength(20)]
        public string FirstName { get; set; }

        [Column(TypeName ="date")]
        public DateTime DateOfBirth { get; set; }

        [Column(TypeName = "decimal(10,3)")]
        [Range(minimum:40, maximum:700)]
        public decimal Weight { get; set; }

        public Guid PersonId { get; set; }
        public List<Address> Addresses { get; set; }
    }
}
