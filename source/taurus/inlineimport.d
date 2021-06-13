module taurus.inlineimport;

/**
Imports a symbol from a module inline. Useful for module dependencies with little
usage.

Checks are done in every symbol, meaning the sequence will fail on the first
invalid symbol. $(BR)
`From` should be used When compiled in **betterC**. Because `from` checks valid
symbols from the start, the program fails if some module depends on something
that isn't supported in **betterC**.
- The following do not compile under `betterC`:
	- **`from.std.traits.isIntegral!byte`**
	- **`from.std.isIntegral!byte`**
	- **`From!"std".isIntegral!byte`**

- The correct way to import is to specify the starting point with `From`:
	- **`From!"std.traits".isIntegral!byte`**

Params: mod = module to search from.

Examples:
---
assert(from.std.traits.isIntegral!byte);
assert(From!"std.array".split("Hello.World", ".") == ["Hello", "World"]);

assert(!__traits(compiles, from.not.exists)); // fails at 'not'
---
*/
enum From(string mod) = FromImpl!mod.init;
enum from = From!null; ///

version (D_BetterC) {} else
/// disabled in betterC due to the usage of dynamic arrays
@safe pure nothrow unittest
{
	assert(from.std.array.split("Hello.World", ".") == ["Hello", "World"]);
	assert(From!"std.array".split("Hello.World", ".") == ["Hello", "World"]);

	assert(from.std.split("Hello.World", ".") == ["Hello", "World"]);
	assert(From!"std".split("Hello.World", ".") == ["Hello", "World"]);
}

///
@safe pure nothrow @nogc unittest
{
	assert(From!"std.math".abs(-1) == 1);
	assert(From!"std.algorithm".max(0, 2, 1) == 2);
}

///
@safe pure nothrow @nogc unittest
{
	assert(!__traits(compiles, { cast(void) from._does.not.exist; }));
	assert(!__traits(compiles, { cast(void) From!"std.algorithm"._; }));
	assert(!__traits(compiles, { cast(void) From!"std.math.abs"(-1); }));
	assert(!__traits(compiles, { assert(From!"std.math.abs(-1)" == 1); }));
}

private struct FromImpl(string mod)
{
	/*
	Returns `FromImpl` if `mod.sym` or `sym` are modules, `aliases to sym` if is a
	valid symbol or `fails`
	*/
	template opDispatch(string sym)
	{
		/*
		order is important:
		- mod is empty -> enum FromImpl!sym
		- mod.sym is valid -> enum FromImpl!mod.sym
		- mod : sym is valid -> alias sym
		*/

		static if (!mod.length)
		{
			static if(isModule!sym)
				enum opDispatch = FromImpl!sym.init;
			else
				alias opDispatch = fail!("Unable to locate module '" ~ sym ~ "'");
		}

		else static if (isModule!(mod, ".", sym))
			enum opDispatch = FromImpl!(mod ~ "." ~ sym).init;

		else
		{
			static if(inModule)
				mixin("import ", mod, ":", sym, "; alias opDispatch = ", sym, ";");
			else
				alias opDispatch = fail!("Symbol '" ~ sym ~ "' not found in module '" ~ mod ~ "'");
		}

		private enum inModule = __traits(compiles, { mixin("import ", mod, ":", sym, ";"); });
	}

	/*
	Helps with code like:
	- from(...)
	- from.std(...)
	- from.std.algorithm(...)
	- From!""(...)
	- From!"std"(...)
	- From!"std.algorithm"(...)
	- From!"std.math.abs"(...)
	*/
	template opCall(Args ...)
	{
		static if (!ModuleCount!mod)
			alias opCall = fail!("Invalid module '"~ mod ~ "' syntax call.");

		else static if (ModuleCount!mod == 1 || isModule!mod)
			alias opCall = fail!("Missing symbol from module '" ~ mod ~ "'!");

		else
			alias opCall = fail!(`Call must be bound to a symbol! Do you mean 'From!"`
				~ mod[0 .. StaticIndexOfLastDot!mod] ~ `".`
				~ mod[StaticIndexOfLastDot!mod + 1 .. $] ~ `'?`);

		// counts possible modules based on '.'
		private template ModuleCount(string s)
		{
			static if (!s.length) enum ModuleCount = 0;
			else static if(StaticIndexOfLastDot!s != -1)
			{
				enum i = StaticIndexOfLastDot!s;

				static if (i == 0 || i + 1 == s.length) enum ModuleCount = 0;
				else enum ModuleCount = 1 + ModuleCount!(s[0 .. i - 1]);
			}
			else enum ModuleCount = 1;
		}

		// gets the index of the last '.' or -1 if none
		private template StaticIndexOfLastDot(string s)
		{
			enum StaticIndexOfLastDot = {
				static foreach_reverse(i, c; s)
					// `if (__ctfe)` is redundant here but avoids the "Unreachable code" warning.
					static if (c == '.') if(__ctfe) return i;
				return -1;
			}();
		}
	}

	// allows to display the static assert error message
	private template fail(string msg)
	{
		noreturn fail(T ...)(auto ref T t) { static assert (false, msg); }
	}

	// check if `T` is importable
	private enum isModule(T ...) = __traits(compiles, { mixin("import ", T, ";"); });
}
