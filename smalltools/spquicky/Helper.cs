using System;
using System.Collections.Generic;
using System.Text;
using System.Diagnostics;
using System.IO;
using System.Data.SqlClient;
using System.Data;

namespace SqlObjectSearch
{
    public class StoreProcView
    {
      

        //string cs = "data source={0};initial catalog={1};user id={2};password={3};";
        string cs = null;
        public  string ConnStr
        {
            get { return cs; }
            set { cs = value; }
        }
        public StoreProcView(string cs)
        {
            this.cs = cs;
        }
        internal  void Sp2File(string spName, string fileName)
        {            
            //cs = string.Format(cs, host, dbName, user, pass);
            using (SqlConnection sqn = new SqlConnection(cs))
            {
                SqlCommand cmd = new SqlCommand("sp_helptext " + spName, sqn);
                cmd.CommandType = CommandType.Text;
                sqn.Open();
                string res = "";
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        res += dr[0].ToString() + "\n";
                    }
                }
                File.WriteAllText(fileName, res, Encoding.GetEncoding(936));
            }
        }

        public void Isqlw(string fileName)
        {
            string cmd = "isqlw.exe ";
            string host = null ;


            string dbName=null;

            string user=null;

            string pass=null;
            string[] csArr = cs.Split(';');
            foreach (string connSingle in csArr)
            {
                string[] connSingleArr = connSingle.Split('=');
                if (connSingleArr.Length != 2) break;
                string prefix = connSingleArr[0].ToUpper();
                string postfix = connSingleArr[1];
                if (prefix == "data source".ToUpper())
                    host = postfix;
                else if (prefix.ToUpper() == "initial catalog".ToUpper())
                    dbName = postfix;
                else if (prefix.ToUpper() == "user id".ToUpper())
                    user = postfix;
                else if (prefix.ToUpper() == "password".ToUpper())
                    pass =  postfix;
            }
            string ar = string.Format(" -S {0} -U{1} -P{2} -d{3} /f {4} ", host,user,pass,dbName,fileName);
            Console.WriteLine(cmd);
            Process.Start(cmd, ar);
        }
        public void Run(string spName)
        {
            Directory.CreateDirectory("temp");
            string fileName = string.Format("temp\\{0}.sql", spName);
            Sp2File(spName, fileName);
            Isqlw(fileName);

        }
    }

}
