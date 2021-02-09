module taurus.traits.types.behaviours;

// FIXME: copyright phobos
/**
 * Returns `true` if T can be iterated over using a `foreach` loop with
 *     a single loop variable of automatically inferred type, regardless of how
 *     the `foreach` loop is implemented.  This includes ranges, structs/classes
 *     that define `opApply` with a single loop variable, and builtin dynamic,
 *     static and associative arrays.
 */
enum bool isIterable(T) = is(typeof({ foreach (elem; T.init) {} }));

///
@safe pure nothrow @nogc
unittest
{
	struct OpApply
	{
		int opApply(scope int delegate(ref uint) dg) { assert(0); }
	}

	struct Range
	{
		@property uint front() { assert(0); }
		void popFront() { assert(0); }
		enum bool empty = false;
	}

	static assert( isIterable!(uint[]));
	static assert( isIterable!OpApply);
	static assert( isIterable!(uint[string]));
	static assert( isIterable!Range);

	static assert(!isIterable!uint);
}


/**
 * Detect whether symbol or type `T` is a function, a function pointer or a delegate.
 *
 * Params: T = type to check.
 *
 * Returns: a `bool`.
 */
template isSomeFunction(T ...)
	if (T.length == 1)
{
	static if ((is(typeof(& T[0]) U : U*) && is(U == function)) || is(typeof(& T[0]) U == delegate))
	{
		// T is a (nested) function symbol.
		enum bool isSomeFunction = true;
	}
	else static if (is(T[0] W) || is(typeof(T[0]) W))
	{
		// T is an expression or a type.  Take the type of it and examine.
		static if (is(W F : F*) && is(F == function))
			enum bool isSomeFunction = true; // function pointer
		else
			enum bool isSomeFunction = is(W == function) || is(W == delegate);
	}
	else
		enum bool isSomeFunction = false;
}

///
@safe pure nothrow @nogc
unittest
{
	static real func(ref int) { return 0; }
	static void prop() @property { }
	class C
	{
		real method(ref int) { return 0; }
		real prop() @property { return 0; }
	}
	scope c = new C;
	auto fp = &func;
	auto dg = &c.method;
	real val;

	static assert( isSomeFunction!func);
	static assert( isSomeFunction!prop);
	static assert( isSomeFunction!(C.method));
	static assert( isSomeFunction!(C.prop));
	static assert( isSomeFunction!(c.prop));
	static assert( isSomeFunction!(c.prop));
	static assert( isSomeFunction!fp);
	static assert( isSomeFunction!dg);

	static assert(!isSomeFunction!int);
	static assert(!isSomeFunction!val);
}

///
@safe pure nothrow @nogc
unittest
{
	void nestedFunc() { }
	void nestedProp() @property { }
	static assert(isSomeFunction!nestedFunc);
	static assert(isSomeFunction!nestedProp);
	static assert(isSomeFunction!(real function(ref int)));
	static assert(isSomeFunction!(real delegate(ref int)));
	static assert(isSomeFunction!((int a) { return a; }));
	static assert(!isSomeFunction!isSomeFunction);
}
