using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace EDennis.MigrationExtensions.ConsoleAppTest {
    public abstract class BaseEntity {
        public int Id { get; set; }

        [MaxLength(255)]
        public string SysUser { get; set; }

        [Column(TypeName ="datetime2")]
        public DateTime SysStart { get; set; }

        [Column(TypeName = "datetime2")]
        public DateTime SysEnd { get; set; }

        [MaxLength(255)]
        public string Filter { get; set; }

    }
}
