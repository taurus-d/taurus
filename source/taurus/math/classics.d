module taurus.math.classics;

static import core.math;

// FIXME: use the isNumeric trait
// FIXME: copyright phobos
inout(T) abs(T)(in inout(T) x)
if ((is(immutable T == immutable short) || is(immutable T == immutable byte)) ||
    (is(typeof(T.init >= 0)) && is(typeof(-T.init))))
{
    // FIXME: use isFoatingPoint trait
    /**
    * Detect whether `T` is a built-in floating point type.
    */
    enum bool isFloatingPoint(T) = __traits(isFloating, T) && !is(T : ireal) && !is(T : creal);
    static if (isFloatingPoint!(T))
        return fabs(x);
    else
    {
        static if (is(immutable T == immutable short) || is(immutable T == immutable byte))
            return x >= 0 ? x : cast(typeof(x)) -int(x);
        else
            return x >= 0 ? x : -x;
    }
}

@safe pure nothrow @nogc
unittest
{
    assert(abs(-4.0) == 4.0);
}


// FIXME: copyright d language foundation
/**
 * Params: x = a floating pointer value.
 *
 * Returns: |x|
 *
 * Special_Values:
 * | x                 | fabs(x)   |
 * | :---------------- | :-------- |
 * | &plusmn;0.0       | +0.0      |
 * | &plusmn;&infin;   | +&infin;  |
 */
pragma(inline, true)
inout(T) fabs(T)(in inout(T) x)
	if (is(T == float) || is( T == double) || is( T == real))
{
	return core.math.fabs(x);
}

///
@safe pure @nogc nothrow
unittest
{
	import taurus.math.introspection : isIdentical;

	assert(isIdentical(fabs(0.0f), 0.0f));
	assert(isIdentical(fabs(-0.0f), 0.0f));
	assert(fabs(-10.0f) == 10.0f);

	assert(isIdentical(fabs(0.0), 0.0));
	assert(isIdentical(fabs(-0.0), 0.0));
	assert(fabs(-10.0) == 10.0);

	assert(isIdentical(fabs(0.0L), 0.0L));
	assert(isIdentical(fabs(-0.0L), 0.0L));
	assert(fabs(-10.0L) == 10.0L);
}
