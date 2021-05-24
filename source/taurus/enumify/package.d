module taurus.enumify;

public import sumtype;

import std.traits : isSomeString;
import std.typecons : Flag, Tuple, tuple;

/**
Defines a new member. `Args` follows the construction format of `Tuple`.

Params:
	name = member name
	Args = types and names(optional)

Examples:
---
enum Foo { A, B }
@Member!("A")
@Member!("B", int, "name")
@Member!("C", byte, long)
@Member!("D", float, char, "name")
@Member!("E", Foo, "nameA", Tuple!(uint, uint), "nameB")
---
*/
struct Member(Args ...)
	if (Args.length > 0
		&& isSomeString!(typeof(Args[0]))
		&& __traits(compiles, { static if (Args.length > 1) Tuple!(Args[1 .. $]) t; })
	)
{}

@safe pure nothrow @nogc unittest {
	assert(!__traits(compiles, Member!()));
	assert(!__traits(compiles, Member!(int)));
	assert(!__traits(compiles, Member!("name", "foo")));
	assert(!__traits(compiles, Member!("name", int, "foo", "bar")));
	assert(!__traits(compiles, Member!("name", int, "foo", short, "foo")));

	assert( __traits(compiles, Member!("A")));
	assert( __traits(compiles, Member!("B", int, "name")));
	assert( __traits(compiles, Member!("C", byte, long)));
	assert( __traits(compiles, Member!("D", float, char, "name")));
	assert( __traits(compiles, Member!("E", int, "nameA", Tuple!(uint, uint), "nameB")));
}

/**
Generate an enum like struct of dynamic values.

Each Member will generate:
 * a *static* method used to instatiate
 * a *struct* to store the data
 * a *private ctor*

Examples:
---
import sumtype;

struct Message {
	@Member!("Move", int, "x", int, "y")
	@Member!("Echo", string)
	@Member!("ChangeColor", uint, uint, uint)
	@Member!("Quit")
	mixin enumify;
}

with (Message) {
Message m = Echo("");
assert(m.match!(
	(echo _) => true,
	_ => false
));

m = ChangeColor(3, 255, 123);
assert(
	m.match!(
		(changecolor c) => c.handle,
		_ => changecolor.handle.init
	) == from.std.typecons.tuple(3, 255, 123)
);
}
---

GenMethods:
```d
static Move(int, int) { ... }
static Echo(string) { ... }
static ChangeColor(uint, uint, uint) { ... }
static Quit() { ... }
```

GenStructs:
 ```d
move { Tuple!(int, "x", int, "y") handle; ... }
echo { string handle; ... }
changecolor { Tuple!(uint, uint, uint) handle; ... }
quit { ... }
```

SumType:
```d
immutable SumType!(move, echo, changecolor, quit) handle;
```

AliasThis: all variables `handle` have `alias this`
```d
alias handle this;
```
*/
mixin template enumify(Flag!"defautToString" defautToString = Flag!"defautToString".yes)
{
	// takes all attributes used before the mixin call
	private struct _udahelper() {}

	import std.ascii : isUpper;
	import std.format : format;
	import std.meta : AliasSeq, Filter, staticMap;
	import std.traits : isType, getUDAs, TemplateArgsOf;
	import std.typecons : Tuple, tuple;

	// Member attribute iteration
	static foreach (attr; getUDAs!(_udahelper, Member))
	{
		static if (TemplateArgsOf!attr.length == 1)
		{
			/*
			Member with name only
			@Member!("None")
			---
			public struct none {
				string toString()() {
					return "None";
				}
			}

			private this(none payload) {
				handle = payload;
			}

			public static None()() {
				return typeof(this)(none());
			}
			---
			*/

			// create struct
			mixin(`public struct `, [ToLower!(TemplateArgsOf!attr[0])], ` {
				string toString()() const { return "`, TemplateArgsOf!attr[0], `"; }
			}`);

			// create ctor
			mixin(`private this()(`, [ToLower!(TemplateArgsOf!attr[0])],` payload) {
				handle = payload;
			}`);

			// create static method
			mixin(`public static `, TemplateArgsOf!attr[0], `()() {
				return typeof(this)(`, [ToLower!(TemplateArgsOf!attr[0])],`());
			}`);
		}
		else static if (TemplateArgsOf!attr.length == 2)
		{
			/*
			Member one type
			@Member!("Some", string)
			---
			public struct some {
				string handle;
				alias handle this;

				version (D_BetterC) {} else
				string toString()() {
					return handle.format!"Some(%s)";
				}
			}

			private this(some payload) {
				handle = payload;
			}

			public static Some()(string seq) {
				return typeof(this)(some(seq));
			}
			---
			*/

			// create struct
			mixin(`public struct `, [ToLower!(TemplateArgsOf!attr[0])], ` {
				`, TemplateArgsOf!attr[1].stringof, ` handle;
				alias handle this;

				version (D_BetterC) {} else
				string toString()() const {
					return format!"`, TemplateArgsOf!attr[0], `(%s)"(handle);
				}
			}`);

			// create ctor
			mixin(`private this()(`, [ToLower!(TemplateArgsOf!attr[0])], ` payload) {
				handle = payload;
			}`);

			// create static method
			mixin(`public static `, TemplateArgsOf!attr[0], `()(`, TemplateArgsOf!attr[1].stringof, ` seq) {
				return typeof(this)(`, [ToLower!(TemplateArgsOf!attr[0])], `(seq));
			}`);
		}
		else
		{
			/*
			Member with either types only or types with names
			@Member!("Some", int, "val")
			---
			public struct some {
				Tuple!(int, "val") handle;
				alias handle this;

				version (D_BetterC) {} else
				string toString()() {
					return handle.format!"Some(%s)";
				}
			}

			private this(some payload) {
				handle = payload;
			}

			public static Some()(AliasSeq!int seq) {
				return typeof(this)(some(seq));
			}
			---
			*/

			// create struct
			mixin(`public struct `, [ToLower!(TemplateArgsOf!attr[0])], ` {
				`, Tuple!(TemplateArgsOf!attr[1 .. $]).stringof, ` handle;
				alias handle this;

				version (D_BetterC) {} else
				string toString()() const {
					import std.range : iota;
					return format!"`, TemplateArgsOf!attr[0], `(%-(%s, %))"(mixin(
						format!"[%(handle[%s].format!\"%%s\"%|, %)]"(handle.length.iota)
					));
				}
			}`);

			// create ctor
			mixin(`private this()(`, [ToLower!(TemplateArgsOf!attr[0])], ` payload) {
				handle = payload;
			}`);

			// create static method
			mixin(`public static `, TemplateArgsOf!attr[0], `()(AliasSeq!`, Filter!(isType, TemplateArgsOf!attr[1 .. $]).stringof, ` seq) {
				return typeof(this)(`, [ToLower!(TemplateArgsOf!attr[0])], `(`, Tuple!(TemplateArgsOf!attr[1 .. $]).stringof, `(seq)));
			}`);
		}
	}

	/**
	Converts a string to lower in CTFE
	*/
	private template ToLower(string s) {
		static if (!s.length)
			alias ToLower = AliasSeq!();
		else
			alias ToLower = AliasSeq!(s[0].isUpper ? cast(char)(cast(char)s[0] + 32) : s[0], ToLower!(s[1 .. $]));
	}
	static assert([ToLower!"Enumify Will Prevail!"] == "enumify will prevail!");

	/**
	Converts the first element of T to lower and adds a comma
	*/
	private enum _front(T) = AliasSeq!([ToLower!(TemplateArgsOf!T[0])], ",");
	static assert(_front!(Member!"Thing") == tuple("thing", ","));

	/*
	generate SumType
	@Member!("Thing")
	@Member!("Ding")
	---
	public SumType!(thing, ding) handle;
	---
	*/
	mixin(`public SumType!(`, staticMap!(_front, getUDAs!(_udahelper, Member)), `) handle;`);
	alias handle this;

	// create opAssign
	public auto opAssign(E : typeof(this))(auto ref E rhs) {
		handle = rhs.handle;
		return this;
	}

	// create toString
	version (D_BetterC) {} else
	static if (defautToString)
	public string toString()() const {
		return handle.match!(_ => _.toString());
	}
}

/// Every type of member
@safe pure nothrow @nogc unittest {
	static struct Foo {
		@Member!("Thing")
		@Member!("Ding", char)
		@Member!("Ming", int, "val")
		mixin enumify;
	}

	static bool isIndexOf(Target, Types...)(SumType!Types st)
	{
		switch (st.typeIndex) {
			static foreach (tid, T; Types)
				case tid: return is(T == Target);
			default: return false;
		}
	}

	with(Foo) assert(isIndexOf!(ming)(Foo.Ming(4)));
	with(Foo) assert(Foo.init == Thing());
	with(Foo) assert(isIndexOf!(thing)(Foo.init));

	version (D_BetterC) {} else
	with (Foo) {
		import localimport;

		Foo foo = Ming(4);
		debug assert(from.std.conv.to!string(foo) == "Ming(4)");
		debug assert(from.std.format!"%s"(foo) == "Ming(4)");
	}
}

/// one type
@safe pure nothrow @nogc unittest {
	static struct Wrapper(T) {
		@Member!("Value", T)
		mixin enumify;
	}

	with (Wrapper!int) assert(Wrapper!int.init == Value(int.init));

	with (Wrapper!int) {
		Wrapper!int w = Value(4);
		assert(w == Value(4));

		// re-assign
		w = Value(15);
		assert(w == Value(15));

		// FIXME: https://issues.dlang.org/show_bug.cgi?id=21975
		// can change internal values
		assert(w.handle.match!((ref value v) => ++v) == 16);

		// copy the internal value
		int i1 = w.handle.match!((value v) => v);
		assert(i1 == 16);

		// can match with `const ref`
		int i2 = w.handle.match!((const ref value v) => v);
		assert(i1 == i2);

		version (D_BetterC) {} else {
			import localimport;

			// string conversion
			debug assert(from.std.conv.to!string(w) == "Value(16)");
			debug assert(from.std.format!"%s"(w) == "Value(16)");
		}
	}

	with (Wrapper!int) {
		alias WType = Wrapper!(Wrapper!int);

		WType w = WType.Value(Value(4));
		assert(w == WType.Value(Value(4)));

		// re-assign
		w = WType.Value(Value(15));
		assert(w == WType.Value(Value(15)));

		version (D_BetterC) {} else {
			import localimport;

			// string conversion
			debug assert(from.std.conv.to!string(w) == "Value(Value(15))");
			debug assert(from.std.format!"%s"(w) == "Value(Value(15))");
		}
	}
}

/// Rustlings example
@safe pure nothrow @nogc unittest {
	static struct Message {
		@Member!("Move", int, "x", int, "y")
		@Member!("Echo", char)
		@Member!("ChangeColor", uint, uint, uint)
		@Member!("Quit")
		mixin enumify;

		bool isMove()() {
			return handle.match!(
				(move _) => true,
				_ => false
			);
		}
	}

	static bool isIndexOf(Target, Types...)(SumType!Types st)
	{
		switch (st.typeIndex) {
			static foreach (tid, T; Types)
				case tid: return is(T == Target);
			default: return false;
		}
	}

	with (Message) {
		assert(Move(4, 5).isMove());

		auto m = Echo(' ');
		assert(isIndexOf!(echo)(m));

		m = ChangeColor(3, 255, 123);
		assert(isIndexOf!(changecolor)(m));

		m.match!(
			(changecolor _) { assert(_ == tuple(3, 255, 123)); },
			(_) { assert(false); }
		);
	}
}
