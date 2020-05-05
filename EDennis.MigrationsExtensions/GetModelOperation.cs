using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
using Microsoft.EntityFrameworkCore.Migrations.Operations;
using System;
using System.Collections.Generic;
using System.Text;

namespace EDennis.MigrationsExtensions {
    public class GetModelOperation : MigrationOperation {
        public Action<IModel> ModelCallback { get; set; }
    }
}
