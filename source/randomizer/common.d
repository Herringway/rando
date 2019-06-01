module randomizer.common;

import libgamestruct.common;
import std.typecons;

enum ColourRandomizationLevel {
	randomHue,
	shiftHue,
	multHue,
	randomSaturation,
	shiftSaturation,
	multSaturation,
	randomValue,
	shiftValue,
	multValue,
	absurd,
	extreme
}

struct Options {
	ColourRandomizationLevel colourRandomizationStyle = ColourRandomizationLevel.shiftHue;
	Nullable!uint seed;
}

void randomizeBase(UDA, alias Func, Game)(ref Game game, const uint seed, const Options options) {
	import std.random : Random, uniform;
	import std.stdio : writeln;
	import std.traits : getSymbolsByUDA, getUDAs, hasUDA;

	auto rand = Random(seed);
	uint nextSeed = seed;

	static foreach (field; getSymbolsByUDA!(Game, UDA)) {{
		enum ctOptions = getUDAs!(field, UDA)[0];
		static if (hasUDA!(field, Label)) {
			enum label = getUDAs!(field, Label)[0];
			writeln("\t- "~label.name~"...");
		}
		debug(verbose) writeln("Randomizing "~field.stringof~"...");
		foreach (ref name; mixin("game."~field.stringof)[]) {
			Func!ctOptions(name, rand, nextSeed, options);
		}
		nextSeed = rand.uniform!uint;
	}}
}
