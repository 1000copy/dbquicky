using System;
using System.Collections.Generic;
using System.Text;

namespace SqlObjectSearch
{
    class ObjectSearch
    {
        string srchKey = "";

        public string SearchKey
        {
            get { return srchKey; }
            set { srchKey = value; }
        }
        string connStr = "";

        public string ConnStr
        {
            get { return connStr; }
            set { connStr = value; }
        }
        int srchObjTypes = 0;

        public int ObjectTypes
        {
            get { return srchObjTypes; }
            set { srchObjTypes = value; }
        }

        List<SearchHit> results = null;

        internal List<SearchHit> Results
        {
            get { return results; }
            set { results = value; }
        }

        internal void PerformSearch()
        {
            results = DataProvider.GetSearchHits(srchKey, connStr, srchObjTypes, 0, null, null, null, null);
        }
    }
}
