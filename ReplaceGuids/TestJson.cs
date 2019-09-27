
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Text.RegularExpressions;

namespace EDennis.NetCoreTestingUtilities {

    public static class JsonTestFileExtensions {


        public static JsonTestCase ReplaceGuids(this JsonTestCase jtc) {
            var jtf = jtc.JsonTestFiles;
            var combined = string.Join((char)60, jtf.OrderBy(e => e.TestFile).Select(e => e.Json));
            var keys = jtf.OrderBy(e => e.TestFile).Select(e => e.TestFile).ToArray();

            var matches = Regex.Matches(combined, "[A-Z0-9]{8}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{12}", RegexOptions.IgnoreCase);
            foreach (var match in matches.Select(m => m.Value).Distinct()) {
                combined = combined.Replace(match, Guid.NewGuid().ToString());
            }
            var values = combined.Split((char)60);
            jtf = Enumerable.Range(0, values.Length)
                .Select(i => new JsonTestFile { TestFile = keys[i], Json = values[i] })
                .ToList();
            jtc.JsonTestFiles = jtf;
            return jtc;
        }

        public static JsonTestCase GetObject<T>(this JsonTestCase jtc, string file, out T obj) {
            obj = jtc.GetObject<T>(file);
            return jtc;
        }



        public static string[] ReplaceGuids(params string[] json) {
            var combined = string.Join((char)60, json);
            var matches = Regex.Matches(combined, "[A-Z0-9]{8}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{12}", RegexOptions.IgnoreCase);
            foreach (var match in matches.Select(m => m.Value).Distinct()) {
                combined = combined.Replace(match, Guid.NewGuid().ToString());
            }
            var result = combined.Split((char)60);
            return result;
        }



    }

}
