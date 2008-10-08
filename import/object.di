module object;

alias typeof(int.sizeof)                    size_t;
alias typeof(cast(void*)0 - cast(void*)0)   ptrdiff_t;

alias size_t hash_t;
alias int equals_t;

alias char[]  string;
alias wchar[] wstring;
alias dchar[] dstring;

class Object
{
    string   toString();
    hash_t   toHash();
    int      opCmp(Object o);
    equals_t opEquals(Object o);

    interface Monitor
    {
        void lock();
        void unlock();
    }
}

struct Interface
{
    ClassInfo   classinfo;
    void*[]     vtbl;
    ptrdiff_t   offset;   // offset to Interface 'this' from Object 'this'
}

class ClassInfo : Object
{
    byte[]      init;   // class static initializer
    string      name;   // class name
    void*[]     vtbl;   // virtual function pointer table
    Interface[] interfaces;
    ClassInfo   base;
    void*       destructor;
    void(*classInvariant)(Object);
    uint        flags;
    //  1:      // is IUnknown or is derived from IUnknown
    //  2:      // has no possible pointers into GC memory
    //  4:      // has offTi[] member
    //  8:      // has constructors
    void*       deallocator;
    OffsetTypeInfo[] offTi;
    void*       defaultConstructor;

    static ClassInfo find(in char[] classname);
    Object create();
}

struct OffsetTypeInfo
{
    size_t   offset;
    TypeInfo ti;
}

class TypeInfo
{
    hash_t   getHash(in void* p);
    equals_t equals(in void* p1, in void* p2);
    int      compare(in void* p1, in void* p2);
    size_t   tsize();
    void     swap(void* p1, void* p2);
    TypeInfo next();
    void[]   init();
    uint     flags();
    // 1:    // has possible pointers into GC memory
    OffsetTypeInfo[] offTi();
}

class TypeInfo_Typedef : TypeInfo
{
    TypeInfo base;
    string   name;
    void[]   m_init;
}

class TypeInfo_Enum : TypeInfo_Typedef
{
}

class TypeInfo_Pointer : TypeInfo
{
    TypeInfo m_next;
}

class TypeInfo_Array : TypeInfo
{
    TypeInfo value;
}

class TypeInfo_StaticArray : TypeInfo
{
    TypeInfo value;
    size_t   len;
}

class TypeInfo_AssociativeArray : TypeInfo
{
    TypeInfo value;
    TypeInfo key;
}

class TypeInfo_Function : TypeInfo
{
    TypeInfo next;
}

class TypeInfo_Delegate : TypeInfo
{
    TypeInfo next;
}

class TypeInfo_Class : TypeInfo
{
    ClassInfo info;
}

class TypeInfo_Interface : TypeInfo
{
    ClassInfo info;
}

class TypeInfo_Struct : TypeInfo
{
    string name;
    void[] m_init;

    uint function(in void*)               xtoHash;
    equals_t function(in void*, in void*) xopEquals;
    int function(in void*, in void*)      xopCmp;
    string function(in void*)             xtoString;

    uint m_flags;

}

class TypeInfo_Tuple : TypeInfo
{
    TypeInfo[]  elements;
}

class ModuleInfo
{
    string          name;
    ModuleInfo[]    importedModules;
    ClassInfo[]     localClasses;
    uint            flags;

    void function() ctor;
    void function() dtor;
    void function() unitTest;

    static int opApply( int delegate( inout ModuleInfo ) );
}

class Exception : Object
{
    interface TraceInfo
    {
        int opApply( int delegate( inout char[] ) );
        string toString();
    }

    string      msg;
    string      file;
    size_t      line;
    TraceInfo   info;
    Exception   next;

    this(string msg, Exception next = null);
    this(string msg, string file, size_t line, Exception next = null);
    override string toString();
}
