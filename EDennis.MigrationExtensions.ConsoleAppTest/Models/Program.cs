using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Migrations;
using Microsoft.EntityFrameworkCore.Migrations.Internal;
using System;

namespace EDennis.MigrationExtensions.ConsoleAppTest
{
    class Program
    {
        static void Main(string[] args)
        {
            using (var context = new PersonAddressContext()) {
                context.Database.Migrate();
            }
            Console.ReadKey();
        }

    }
}
