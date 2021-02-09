module taurus.math.introspection;

import taurus.math.internal : floatTraits, RealFormat;


// FIXME: copyright phobos
// FIXME: copyright d language foundation
/**
 * Is the binary representation of x identical to y?
 *
 * Params: x, y = values to compare.
 *
 * Returns: `true` if the binary representation is identical, `false` otherwise.
 */
@trusted pure nothrow @nogc
bool isIdentical(in real x, in real y)
{
    // We're doing a bitwise comparison so the endianness is irrelevant.
    immutable pxs = cast(immutable(long*)) &x;
    immutable pys = cast(immutable(long*)) &y;
    alias F = floatTraits!real;

    static if (F.realFormat == RealFormat.ieeeDouble)
    {
        return pxs[0] == pys[0];
    }
    else static if (F.realFormat == RealFormat.ieeeQuadruple)
    {
        return pxs[0] == pys[0] && pxs[1] == pys[1];
    }
    else static if (F.realFormat == RealFormat.ieeeExtended)
    {
        immutable pxe = cast(immutable(ushort*)) &x;
        immutable pye = cast(immutable(ushort*)) &y;
        return pxe[4] == pye[4] && pxs[0] == pys[0];
    }
    else
    {
        assert(0, "isIdentical not implemented");
    }
}

///
@safe pure nothrow @nogc
unittest
{
    assert(isIdentical(0.0, 0.0));
    assert(isIdentical(1.0, 1.0));
    assert(isIdentical(real.infinity, real.infinity));
    assert(isIdentical(-real.infinity, -real.infinity));

    assert(!isIdentical(0.0, -0.0));
    assert(!isIdentical(real.nan, -real.nan));
    assert(!isIdentical(real.infinity, -real.infinity));
}
