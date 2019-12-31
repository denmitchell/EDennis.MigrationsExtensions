using System;
using System.IO;
using System.Text.RegularExpressions;
using System.Linq;
using EDennis.NetCoreTestingUtilities;
using System.Collections.Generic;
using System.Text.Json;
using ReplaceGuids;

namespace ReplaceGuidsNs {
    class Program {


        public static void Main(string[] _) {


            string baseJson = File.ReadAllText("base.json");
            string inputJson = File.ReadAllText("input.json");
            string expectedJson = File.ReadAllText("expected.json");

            var jsonTestCase = new JsonTestCase {
                ProjectName = "Project",
                ClassName = "Class",
                MethodName = "Method",
                TestScenario = "TestScenario",
                TestCase = "TestCase",
                JsonTestFiles = new List<JsonTestFile> {
                    new JsonTestFile { TestFile = "Base", Json = baseJson},
                    new JsonTestFile { TestFile = "Input", Json = inputJson},
                    new JsonTestFile { TestFile = "Expected", Json = expectedJson},
                }
            };

            //[TestJson_("SomeMethod", "", "SomeTestCase")]
            //public void SomeMethod(string t, JsonTestCase jsonTestCase) {

            //
            //current way of retrieving data from TestJsonTable...
            //
            //var baseRecs = jsonTestCase.GetObject<List<Person>>("Base");
            //var input = jsonTestCase.GetObject<Person>("Expected");
            //var expected = jsonTestCase.GetObject<List<Person>>("Base");


            //new way with method chaining ...
            jsonTestCase
                .ReplaceGuids()    //replace placemarker guids with test-specific guids
                .GetObject("Base", out List<Person> baseRecs)       
                .GetObject("Input", out Person input)              
                .GetObject("Expected", out List<Person> expected); 

           
            //...
            Console.WriteLine(JsonSerializer.Serialize(baseRecs));
            Console.WriteLine(JsonSerializer.Serialize(input));
            Console.WriteLine(JsonSerializer.Serialize(expected));

            Console.ReadKey();
        }


    }

}
