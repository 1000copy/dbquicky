using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;

namespace SqlObjectSearch
{
    /// <summary>
    /// Data access methods for SQL Server object search.
    /// </summary>
    /// <remarks>This class uses the Microsoft sp_MSobjectsearch stored procedure to perform an object search on a SQL Server instance.</remarks>
    class DataProvider
    {
        private static Dictionary<string, ObjectType> objectTypes = new Dictionary<string, ObjectType>();
        private static Dictionary<string, int> objectTypeBitValues = new Dictionary<string, int>();
        private static int allObjectsValue = 0;

        static DataProvider()
        {
            // Used object types.
            objectTypes.Add("U", new ObjectType("U", "Table (user-defined)", 1));
            objectTypes.Add("S", new ObjectType("S", "System base table", 2));
            objectTypes.Add("V", new ObjectType("V", "View", 4));
            objectTypes.Add("P", new ObjectType("P", "SQL stored procedure", 8));
            //objectTypes.Add("RF", new SqlObjectType("RF", "Replication-filter-procedure", 16));
            objectTypes.Add("X", new ObjectType("X", "Extended stored procedure", 32));
            objectTypes.Add("TR", new ObjectType("TR", "SQL DML trigger", 64));
            objectTypes.Add("FN", new ObjectType("FN", "SQL scalar function", 128));
            objectTypes.Add("PK", new ObjectType("PK", "PRIMARY KEY constraint", 256));
            //objectTypes.Add("L", new SqlObjectType("L", "Log", 512));                                 // Need to check short name.
            objectTypes.Add("COL", new ObjectType("COL", "Column", 1024));                              // Not a standard sysobjects type.
            objectTypes.Add("I", new ObjectType("I", "Index", 2048));                                   // Not a standard sysobjects type.

            // To be used object types.
            objectTypes.Add("AF", new ObjectType("AF", "Aggregate function (CLR)", 0));
            objectTypes.Add("C", new ObjectType("C", "CHECK constraint", 0));
            objectTypes.Add("D", new ObjectType("D", "DEFAULT (constraint or stand-alone)", 0));
            objectTypes.Add("F", new ObjectType("F", "FOREIGN KEY constraint", 0));
            objectTypes.Add("PC", new ObjectType("PC", "Assembly (CLR) stored procedure", 0));
            objectTypes.Add("FS", new ObjectType("FS", "Assembly (CLR) scalar function", 0));
            objectTypes.Add("FT", new ObjectType("FT", "Assembly (CLR) table-valued function", 0));
            objectTypes.Add("R", new ObjectType("R", "Rule (old-style, stand-alone)", 0));
            objectTypes.Add("SN", new ObjectType("SN", "Synonym", 0));
            objectTypes.Add("SQ", new ObjectType("SQ", "Service queue", 0));
            objectTypes.Add("TA", new ObjectType("TA", "Assembly (CLR) DML trigger", 0));
            objectTypes.Add("IF", new ObjectType("IF", "SQL inline table-valued function", 0));
            objectTypes.Add("TF", new ObjectType("TF", "SQL table-valued-function", 0));
            objectTypes.Add("UQ", new ObjectType("UQ", "UNIQUE constraint", 0));
            objectTypes.Add("IT", new ObjectType("IT", "Internal table", 0));
        }

        internal static Dictionary<string, ObjectType> ObjectTypes
        {
            get { return objectTypes; }
        }

        internal static List<SearchHit> GetSearchHits(string searchKey, string cs, int? objectType, int? hitLimit, int? caseSensitive, int? status, string extPropName, string extPropValue)
        {
            List<SearchHit> results = new List<SearchHit>();
            using (SqlConnection sqn = new SqlConnection(cs))
            {
                SqlCommand cmd = new SqlCommand("sp_MSobjsearch", sqn);
                cmd.CommandType = CommandType.StoredProcedure;
                AddParameter(cmd, "@searchkey", searchKey);
                AddParameter(cmd, "@dbname", null);
                AddParameter(cmd, "@objecttype", objectType);
                AddParameter(cmd, "@hitlimit", hitLimit);
                AddParameter(cmd, "@casesensitive", caseSensitive);
                AddParameter(cmd, "@status", status);
                AddParameter(cmd, "@extpropname", extPropName);
                AddParameter(cmd, "@extpropvalue", extPropValue);
                
                sqn.Open();
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        SearchHit hit = new SearchHit();
                        PopulateHit(hit, dr);
                        results.Add(hit);
                    }
                }
            }
            return results;
        }

        internal static int ValueOfAllObjectTypes
        {
            get
            {
                if (allObjectsValue == 0)
                {
                    foreach (ObjectType obj in objectTypes.Values)
                    {
                        allObjectsValue += obj.BitValue;
                    }
                }
                return allObjectsValue;
            }
        }

        private static void AddParameter(SqlCommand cmd, string paramName, object paramValue)
        {
            if (paramValue != null)
            {
                cmd.Parameters.Add(new SqlParameter(paramName, paramValue));
            }
        }

        private static void PopulateHit(SearchHit hit, IDataReader reader)
        {
            hit.dbName = reader["dbname"].ToString();
            hit.owner = reader["owner"].ToString();
            hit.objectName = reader["objname"].ToString();
            hit.objectType = reader["objtype"].ToString();
            hit.objectTable = reader["objtab"].ToString();
        }
    }
}
