// file generated by EDennis.DataScaffolder
// using connection string(s) from appsettings.Development.json
using System;
namespace EDennis.MigrationExtensions.ConsoleAppTest
{
    public static partial class PersonAddressContextDataFactory
    {
        public static Address[] dbo_AddressRecords { get; set; }
        /*= new Address[] {
            new Address {
                    PersonId = 1,
                    AddressId = 1,
                    Street = "123 Main Street",
                    SysUser = 0,
            },
            new Address {
                    PersonId = 2,
                    AddressId = 2,
                    Street = "321 Second Avenue;",
                    SysUser = 0,
            },
        };*/
        public static Person[] dbo_PersonRecords { get; set; }
        /*= new Person[] {
            new Person {
                    PersonId = 1,
                    FirstName = "Bob",
                    DateOfBirth = new DateTime(1980,4,23,0,0,0),
                    Weight = 160.000M,
                    SysUserId = 0,
            },
            new Person {
                    PersonId = 2,
                    FirstName = "Lisa",
                    DateOfBirth = new DateTime(1981,5,24,0,0,0),
                    Weight = 110.000M,
                    SysUserId = 0,
            },

    };*/
    }
}
