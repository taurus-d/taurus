module taurus.typecons.result;

import std.algorithm : splitter;
import std.format : format;
import std.conv : to;
import std.range : front;
import std.traits : isInstanceOf, ReturnType;


Result!(OkT, T) ok(T, OkT)(OkT value)
{
	Result!(OkT, T) res = Result!(OkT, T).Ok(value);
	return res;
}

Result!(OkT, T) ok(T, OkT = void)()
{
	Result!(OkT, T) res = Result!(OkT, T).Ok();
	return res;
}


auto Ok(OkT, string prettyFunction = __PRETTY_FUNCTION__, string functionName = __FUNCTION__)(OkT value)
{
	alias retType = mixin(prettyFunction.splitter(""~functionName).front);
	auto res = retType.Ok(value);
	return res;
}

auto Ok(OkT = void, string prettyFunction = __PRETTY_FUNCTION__, string functionName = __FUNCTION__)()
{
	alias retType = mixin(prettyFunction.splitter(""~functionName).front);
	auto res = retType.Ok();
	return res;
}


Result!(T, ErrT) err(T, ErrT)(ErrT value)
{
	Result!(T, ErrT) res = Result!(T, ErrT).Err(value);
	return res;
}

Result!(T, ErrT) err(T, ErrT = void)()
{
	Result!(T, ErrT) res = Result!(T, ErrT).Err();
	return res;
}


auto Err(ErrT, string prettyFunction = __PRETTY_FUNCTION__, string functionName = __FUNCTION__)(ErrT value)
{
	alias retType = mixin(prettyFunction.splitter(""~functionName).front);
	auto res = retType.Err(value);
	return res;
}

auto Err(ErrT = void, string prettyFunction = __PRETTY_FUNCTION__, string functionName = __FUNCTION__)()
{
	alias retType = mixin(prettyFunction.splitter(""~functionName).front);
	auto res = retType.Err();
	return res;
}


mixin template makeResult()
{
	static assert (isInstanceOf!(Result, typeof(return)));
	alias Ok = typeof(return).Ok;
	alias Err = typeof(return).Err;
}


struct Result(OkT, ErrT)
{
	static if (!is(OkT == void))
	{
		@trusted pure nothrow @nogc
		static Result!(OkT, ErrT) Ok(OkT value)
		{
			Result!(OkT, ErrT) res;
			res._payload._ok = ok(value);
			res._state = State.Ok;
			return res;
		}
	}
	else
	{

		@trusted pure nothrow @nogc
		static Result!(OkT, ErrT) Ok()
		{
			Result!(OkT, ErrT) res;
			res._payload._ok = ok();
			res._state = State.Ok;
			return res;
		}
	}

	static if (!is(ErrT == void))
	{
		@trusted pure nothrow @nogc
		static Result!(OkT, ErrT) Err(ErrT value)
		{
			Result!(OkT, ErrT) res;
			res._payload._err = err(value);
			res._state = State.Err;
			return res;
		}
	}
	else
	{
		@trusted pure nothrow @nogc
		static Result!(OkT, ErrT) Err()
		{
			Result!(OkT, ErrT) res;
			res._payload._err = err();
			res._state = State.Err;
			return res;
		}
	}

	@safe pure nothrow @nogc
	bool isOk() const
	{
		return _state == State.Ok;
	}

	@safe pure nothrow @nogc
	bool isErr() const
	{
		return !isOk();
	}

	@trusted pure @property
	OkT except(lazy const string msg) inout
	{
		static if (!is(OkT == void))
		{
			if (isOk()) return _payload._ok._handle;
			else assert(false, format!"%s: %s" (msg, _payload._err));
		}
	}

	@trusted pure @property
	OkT unwrap() inout
	{
		static if (!is(OkT == void))
		{
			if (isOk()) return _payload._ok._handle;
			else assert(false, _payload._err.toString);
		}
	}

	@trusted pure @property
	ErrT exceptErr(in string msg) inout
	{
		static if (!is(ErrT == void))
		{
			if (isErr()) return _payload._err._handle;
			else assert(false, format!"%s: %s" (msg, _payload._ok));
		}
	}

	@trusted pure @property
	ErrT unwrapErr() inout
	{
		static if (!is(ErrT == void))
		{
			if (isErr()) return _payload._err._handle;
			else assert(false, _payload._ok.toString);
		}
	}

	@trusted pure @property
	string toString() const
	{
		return isOk
			? "Ok("~_payload._ok.toString~")"
			: "Err("~_payload._err.toString~")";
	}

private:
	union Payload
	{
		ok _ok;
		err _err;
	}

	struct ok
	{
		static if (is(OkT == void))
		{
			@safe pure @property string toString() const { return ""; }
		}
		else
		{
			@safe pure @property string toString() const { return _handle.to!string;}
			OkT _handle = OkT.init;
		}
	}

	struct err
	{
		static if (is(ErrT == void))
		{
			@safe pure string toString() @property const { return ""; }
		}
		else
		{
			@safe pure string toString() @property const { return _handle.to!string; }
			ErrT _handle;
		}
	}

	enum State
	{
		Ok,
		Err,
	}

	Payload _payload;
	State _state = State.Ok;
}

@safe pure nothrow @nogc
unittest
{
	{
		auto res = ok!string(3);
		assert(is(typeof(res) == Result!(int, string)));
		assert(res.isOk);
		assert(res == Result!(int,string).Ok(3));
	}

	{
		@safe pure nothrow @nogc
		Result!(int, string) filled(int a)
		{
			if (a > 0) return Ok(a);
			else return Err("Value must be greater than 0!");
		}

		assert(filled(0).isErr);
		assert(filled(1).isOk);
	}

	{
		@safe pure nothrow @nogc
		Result!(void, void) empty(int a)
		{
			if (a > 0) return Ok();
			else return Err();
		}

		assert(empty(0).isErr);
		assert(empty(1).isOk);
	}

	{
		struct Foo {}
		Result!(Foo, int) res;

		Result!(Foo, void) e(int a)
		{
			mixin makeResult;
			if (a > 0) return Ok(Foo());
			else return Err();
		}
	}
}

@trusted pure
unittest
{
	import core.exception : AssertError;
	import std.exception : assertThrown;

	@safe pure nothrow @nogc
	Result!(int, string) test(int a)
	{
		mixin makeResult;
		if (a > 0) return Ok(a);
		else return Err("Value must be greater than 0!");
	}

	assert(3 == test(3).unwrap);
	assert(3 == test(3).except("This won't fail."));
	assertThrown!AssertError(test(0).unwrap, "Value must be greater than 0!");
	assertThrown!AssertError(test(0).except("This fails"), "This fails: Value must be greater than 0!");
}

@trusted pure
unittest
{
	import core.exception : AssertError;
	import std.exception : assertThrown;

	{
		Result!(int, int) res;
		assert(res.isOk());
		assert(int.init == res.unwrap);
		assert("Ok(0)" == res.toString);
	}

	{
		auto res = Result!(int, int).Err(5);
		assert(res.isErr());
		assert(err!int(5) == res);
		assert(5 == res.unwrapErr);
		assert("Err(5)" == res.toString);
	}

	{
		auto res = Result!(Result!(int, string), string).Ok(err!int("error"));
		assert(res.isOk());
		assert(ok!string(err!int("error")) == res);
		assert("error" == res.unwrap.unwrapErr);
		assert("Ok(Err(error))" == res.toString);
	}

	{
		auto res = err!int(ok!string(3));
		assert(res.isErr());
		assertThrown!AssertError(res.unwrap, "Ok(3)");
	}

	{
		auto res = Result!(void, string).Ok();
		assert(!__traits(compiles, { auto result = res.unwrap; }));
	}
}
