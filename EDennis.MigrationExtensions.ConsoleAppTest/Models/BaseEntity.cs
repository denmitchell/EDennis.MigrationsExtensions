using System;
using System.Collections.Generic;
using System.Text;

namespace EDennis.MigrationExtensions.ConsoleAppTest
{
    public abstract class BaseEntity {
        public int Id { get; set; }
        public string SysUser { get; set; }
        public DateTime SysStart { get; set; }
        public DateTime SysEnd { get; set; }
        public string Filter { get; set; }

    }
}
