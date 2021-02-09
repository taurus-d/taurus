module taurus.meta.usage;

// FIXME: copyright phobos
/**
 * Allows `alias`ing of any single symbol, type or compile-time expression.
 *
 * Not everything can be directly aliased. An alias cannot be declared of - for
 *     example - a literal:
 *
 * Examples:
 * --------------------
 * alias a = 4; //Error
 * alias b = Alias!4; //OK
 * --------------------
 */
alias Alias(alias a) = a;


///
alias Alias(T) = T;

///
@safe pure nothrow @nogc
unittest
{
	// Without Alias this would fail if Args[0] was e.g. a value and
	// some logic would be needed to detect when to use enum instead
	alias Head(Args...) = Alias!(Args[0]);
	alias Tail(Args...) = Args[1 .. $];

	alias Blah = AliasSeq!(3, int, "hello");
	static assert(Head!Blah == 3);
	static assert(is(Head!(Tail!Blah) == int));
	static assert((Tail!Blah)[1] == "hello");
}

///
@safe pure nothrow @nogc
unittest
{
	alias a = Alias!(123);
	static assert(a == 123);

	enum abc = 1;
	alias b = Alias!(abc);
	static assert(b == 1);

	alias c = Alias!(3 + 4);
	static assert(c == 7);

	alias concat = (s0, s1) => s0 ~ s1;
	alias d = Alias!(concat("Hello", " World!"));
	static assert(d == "Hello World!");

	alias e = Alias!(int);
	static assert(is(e == int));

	alias f = Alias!(AliasSeq!(int));
	static assert(!is(typeof(f[0]))); //not an AliasSeq
	static assert(is(f == int));

	auto g = 6;
	alias h = Alias!g;
	++h;
	assert(g == 7);
}


/**
 * Creates a sequence of zero or more aliases. This is most commonly
 *     used as template parameters or arguments.
 */
alias AliasSeq(TList...) = TList;

///
@safe pure nothrow @nogc
unittest
{
	import std.meta;
	alias TL = AliasSeq!(int, double);

	int foo(TL td)  // same as int foo(int, double);
	{
		return td[0] + cast(int) td[1];
	}

	assert(3 == foo(2, 1.0));
}

///
@safe pure nothrow @nogc
unittest
{
	alias TL = AliasSeq!(int, double);

	alias Types = AliasSeq!(TL, char);
	static assert(is(Types == AliasSeq!(int, double, char)));
}
