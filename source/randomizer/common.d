module randomizer.common;

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
