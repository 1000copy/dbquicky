using System;
using System.Collections.Generic;
using System.Text;

namespace SqlObjectSearch
{
    struct ObjectType
    {
        internal string Type;
        internal string Name;
        internal int BitValue;

        internal ObjectType(string type, string name, int bitValue)
        {
            this.Type = type;
            this.Name = name;
            this.BitValue = bitValue;
        }
    }
}
