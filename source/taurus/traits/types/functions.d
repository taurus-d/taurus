module taurus.traits.types.functions;

import taurus.traits.types.behaviours : isCallable;

// FIXME: copyright phobos
/**
 * Get the function type from a callable object `func`.
 *
 * Using builtin `typeof` on a property function yields the types of the
 *     property value, not of the property function itself. Still, `FunctionTypeOf`
 *     is able to obtain function types of properties.
 *
 * Note: do not confuse function types with function pointer types; function
 *     types are usually used for compile-time reflection purposes.
 */
template FunctionTypeOf(func...)
if (func.length == 1 && isCallable!func)
{
    static if (is(typeof(& func[0]) Fsym : Fsym*) && is(Fsym == function) || is(typeof(& func[0]) Fsym == delegate))
    {
        alias FunctionTypeOf = Fsym; // HIT: (nested) function symbol
    }
    else static if (is(typeof(& func[0].opCall) Fobj == delegate))
    {
        alias FunctionTypeOf = Fobj; // HIT: callable object
    }
    else static if (is(typeof(& func[0].opCall) Ftyp : Ftyp*) && is(Ftyp == function))
    {
        alias FunctionTypeOf = Ftyp; // HIT: callable type
    }
    else static if (is(func[0] T) || is(typeof(func[0]) T))
    {
        static if (is(T == function))
            alias FunctionTypeOf = T;    // HIT: function
        else static if (is(T Fptr : Fptr*) && is(Fptr == function))
            alias FunctionTypeOf = Fptr; // HIT: function pointer
        else static if (is(T Fdlg == delegate))
            alias FunctionTypeOf = Fdlg; // HIT: delegate
        else
            static assert(0);
    }
    else
        static assert(0);
}

///
@safe pure nothrow @nogc
unittest
{
    class C
    {
        int value() @property { return 0; }
    }
    static assert(is( typeof(C.value) == int ));
    static assert(is( FunctionTypeOf!(C.value) == function ));
}

///
@safe pure nothrow @nogc
unittest
{
    @safe pure nothrow @nogc int test(int a);
    @safe pure nothrow @nogc int propGet() @property;
    @safe pure nothrow @nogc int propSet(int a) @property;
    int function(int) @safe pure nothrow @nogc test_fp;
    int delegate(int) @safe pure nothrow @nogc test_dg;
    static assert(is( typeof(test) == FunctionTypeOf!(typeof(test)) ));
    static assert(is( typeof(test) == FunctionTypeOf!test ));
    static assert(is( typeof(test) == FunctionTypeOf!test_fp ));
    static assert(is( typeof(test) == FunctionTypeOf!test_dg ));
    alias int GetterType() @safe pure nothrow @nogc @property;
    alias int SetterType(int) @safe pure nothrow @nogc @property;
    static assert(is( FunctionTypeOf!propGet == GetterType ));
    static assert(is( FunctionTypeOf!propSet == SetterType ));

    interface Prop { int prop() @safe pure nothrow @nogc @property; }
    Prop prop;
    static assert(is( FunctionTypeOf!(Prop.prop) == GetterType ));
    static assert(is( FunctionTypeOf!(prop.prop) == GetterType ));

    class Callable { @safe pure nothrow @nogc int opCall(int) { return 0; } }
    scope call = new Callable;
    static assert(is( FunctionTypeOf!call == typeof(test) ));

    struct StaticCallable { static pure nothrow @nogc int opCall(int) { return 0; } }
    StaticCallable stcall_val;
    StaticCallable* stcall_ptr;
    static assert(is( FunctionTypeOf!stcall_val == typeof(test) ));
    static assert(is( FunctionTypeOf!stcall_ptr == typeof(test) ));

    interface Overloads
    {
        void test(string);
        real test(real);
        int  test(int);
        int  test() @property;
    }
    alias ov = __traits(getVirtualFunctions, Overloads, "test");
    alias F_ov0 = FunctionTypeOf!(ov[0]);
    alias F_ov1 = FunctionTypeOf!(ov[1]);
    alias F_ov2 = FunctionTypeOf!(ov[2]);
    alias F_ov3 = FunctionTypeOf!(ov[3]);
    static assert(is(F_ov0* == void function(string)));
    static assert(is(F_ov1* == real function(real)));
    static assert(is(F_ov2* == int function(int)));
    static assert(is(F_ov3* == int function() @property));

    alias F_dglit = FunctionTypeOf!((int a){ return a; });
    static assert(is(F_dglit* : int function(int)));
}
