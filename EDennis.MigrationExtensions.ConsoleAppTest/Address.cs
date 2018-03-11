using System;

namespace CodeFirstPractice {
    public class Address {
        public int PersonId { get; set; }
        public int AddressId { get; set; }
        public string Street { get; set; }

        public int SysUserId { get; set; }
        public DateTime SysStart { get; set; }
        public DateTime SysEnd { get; set; }

        public Person Person { get; set; }
    }
}