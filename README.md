# Taurus
Taurus is a library focused in creating functional code. It will use as it's
core types, `Option` and `Result`, which depend on SumType. Taurus will not be
focused on creating a lib GC free, as it will use some of the Phobos modules as
dependencies, however, every new internal implementation will try to avoid GC usage
when possible.

## Future
```d
import taurus;
import std.string;

void main() {
	string[] str = ["1", "123", "invalid", "44"];

	assert(str.map!(parse!int).equal(Option!int.Some(1), Option!int.Some(123), Option!int.None, Option!int.Some(44)));
	assert(str.map!(parse!int).filterMap.equal(1, 123, 44));
}
