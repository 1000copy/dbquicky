using System;
using System.Collections.Generic;
using System.Text;
using System.Data;

namespace SqlObjectSearch
{
    public class SearchHit
    {
        #region Constructors

        /// <summary>
        /// Describes a search hit for a SQL Server object search.
        /// </summary>

        public SearchHit()
        {
        }

        #endregion
        #region Properties

        internal string dbName = "";
        public string DBName
        {
            get { return dbName; }
            set { dbName = value; }
        }
        internal string owner = "";
        public string Owner
        {
            get { return owner; }
            set { owner = value; }
        }
        internal string objectName = "";
        public string ObjectName
        {
            get { return objectName; }
            set { objectName = value; }
        }
        internal string objectType = "";
        public string ObjectType
        {
            get { return objectType; }
            set { objectType = value.Trim(); }
        }
        public string ObjectTypeName
        {
            get
            {
                if (DataProvider.ObjectTypes.ContainsKey(this.objectType.Trim()))
                {
                    return DataProvider.ObjectTypes[this.objectType.Trim()].Name;
                }
                else
                {
                    return "#unknown object type#";
                }
            }
        }
        internal string objectTable = "";
        public string ObjectTable
        {
            get { return objectTable; }
            set { objectTable = value; }
        }

        #endregion
    }
}
