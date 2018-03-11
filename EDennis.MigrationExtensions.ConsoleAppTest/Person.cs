using System;
using System.Collections.Generic;
using System.Text;

namespace CodeFirstPractice {
    public class Person {
        public int PersonId { get; set; }
        public string FirstName { get; set; }
        public DateTime DateOfBirth { get; set; }
        public decimal Weight { get; set; }

        public int SysUserId { get; set; }
        public DateTime SysStart { get; set; }
        public DateTime SysEnd { get; set; }

        public List<Address> Addresses { get; set; }
    }
}
