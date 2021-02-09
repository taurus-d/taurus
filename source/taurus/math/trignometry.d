module taurus.math.trignometry;

static import core.math;

// FIXME: copyright d language foundation
/**
 * Params: x = value in radians.
 *
 * Special_Values:
 * | x                | cos(x)     |
 * | :--------------- | :--------- |
 * | $(RED NAN)       | $(RED NAN) |
 * | &plusmin;&infin; | $(RED NAN) |
 *
 * Bugs:
 *     Results are undefined if |x| >= $(POWER 2,64).
 *
 * Returns: cosine of x.
 */
pragma(inline, true)
inout(T) cos(T)(in inout(T) x)
	if(is(T == float) || is(T == double) || is(T == real))
{
	return core.math.cos(x);
}

@safe pure nothrow @nogc
unittest
{
	// FIXME: refactor unittests when aproxEqual is implemented
	import taurus.math.constants : PI, PI_2;

	assert(cos(0.0f) == 1.0f);
	assert(cos(PI) == -1.0f);

	assert(cos(0.0) == 1.0);
	assert(cos(PI) == -1.0);

	assert(cos(0.0L) == 1.0L);
	assert(cos(PI) == -1.0L);
}


// FIXME: copyright d language foundation
/**
 * Params: x = value in radians.
 *
 * Special_Values:
 * | x                | sin(x)       | invalid? |
 * | :--------------- | :----------- | :------- |
 * | $(RED NAN)       | $(RED NAN)   | yes      |
 * | &plusmin;0.0     | &plusmin;0.0 | no       |
 * | &plusmin;&infin; | $(RED NAN)   | yes      |
 *
 * Bugs:
 *     Results are undefined if |x| >= $(POWER 2,64).
 *
 * Returns: sine of x.
 */
pragma(inline, true)
inout(T) sin(T)(in inout(T) x)
	if(is(T == float) || is(T == double) || is(T == real))
{
	return core.math.sin(x);
}

@safe pure nothrow @nogc
unittest
{
	// FIXME: refactor unittests when aproxEqual is implemented
	import taurus.math.constants : PI_2;

	assert(sin(0.0f) == 0.0f);
	assert(sin(PI_2) == 1.0f);

	assert(sin(0.0) == 0.0);
	assert(sin(PI_2) == 1.0);

	assert(sin(0.0L) == 0.0L);
	assert(sin(PI_2) == 1.0L);
}
