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
