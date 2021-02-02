module taurus.math.trignometry.cos;

/***********************************
 * Returns cosine of x. x is in radians.
 *
 *      $(TABLE_SV
 *      $(TR $(TH x)                 $(TH cos(x)) $(TH invalid?))
 *      $(TR $(TD $(NAN))            $(TD $(NAN)) $(TD yes)     )
 *      $(TR $(TD $(PLUSMN)$(INFIN)) $(TD $(NAN)) $(TD yes)     )
 *      )
 * Bugs:
 *      Results are undefined if |x| >= $(POWER 2,64).
 */
pragma(inline, true)
T cos(T)(T x)
	if(is(T == float) || is(T == double) || is(T == real))
{
	return core.math.cos(x);
}
