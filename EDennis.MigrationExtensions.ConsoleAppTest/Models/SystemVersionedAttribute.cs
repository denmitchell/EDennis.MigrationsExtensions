using System;
using System.Collections.Generic;
using System.Text;

namespace EDennis.MigrationExtensions.ConsoleAppTest.Models {

    [System.AttributeUsage(System.AttributeTargets.Class, AllowMultiple = false)]
    public class SystemVersionedAttribute : Attribute {
        public string HistorySchema { get; set; } = "dbo_history";
        public string HistoryTable { get; set; }
        public string SysStartColumn { get; set; } = "SysStart";
        public string SysEndColumn { get; set; } = "SysEnd";
    }
}
