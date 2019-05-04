module randomizer.palette;

import libgamestruct.common;
import pixelatrix.color;

import randomizer.common;

T[] randomizePalette(T)(T[] input, ColourRandomizationLevel randomizationLevel, uint seed) {
	import std.algorithm.iteration : map;
	import std.algorithm.comparison : min;
	import std.array : array;
	import std.random : Random, uniform01;

	auto rand = Random(seed);
	const randomConstant = rand.uniform01();
	final switch (randomizationLevel) {
		case ColourRandomizationLevel.shiftHue:
			return input[0..$].map!(x => x.toHSV).map!(x => HSV((x.hue + randomConstant) % 1.0, x.saturation, x.value)).map!(x => x.toRGB!T).array;
		case ColourRandomizationLevel.multHue:
			return input[0..$].map!(x => x.toHSV).map!(x => HSV((x.hue * randomConstant * 2.0) % 1.0, x.saturation, x.value)).map!(x => x.toRGB!T).array;
		case ColourRandomizationLevel.randomHue:
			return input[0..$].map!(x => x.toHSV).map!(x => HSV(rand.uniform01(), x.saturation, x.value)).map!(x => x.toRGB!T).array;
		case ColourRandomizationLevel.randomSaturation:
			return input[0..$].map!(x => x.toHSV).map!(x => HSV(x.hue, rand.uniform01(), x.value)).map!(x => x.toRGB!T).array;
		case ColourRandomizationLevel.shiftSaturation:
			return input[0..$].map!(x => x.toHSV).map!(x => HSV(x.hue, (x.saturation + randomConstant) % 1.0, x.value)).map!(x => x.toRGB!T).array;
		case ColourRandomizationLevel.multSaturation:
			return input[0..$].map!(x => x.toHSV).map!(x => HSV(x.hue, min(x.saturation * randomConstant * 2.0, 1.0), x.value)).map!(x => x.toRGB!T).array;
		case ColourRandomizationLevel.randomValue:
			return input[0..$].map!(x => x.toHSV).map!(x => HSV(x.hue, x.saturation, rand.uniform01())).map!(x => x.toRGB!T).array;
		case ColourRandomizationLevel.shiftValue:
			return input[0..$].map!(x => x.toHSV).map!(x => HSV(x.hue, x.saturation, (x.value + randomConstant) % 1.0)).map!(x => x.toRGB!T).array;
		case ColourRandomizationLevel.multValue:
			return input[0..$].map!(x => x.toHSV).map!(x => HSV(x.hue, x.saturation, min(x.value * randomConstant * 2.0, 1.0))).map!(x => x.toRGB!T).array;
		case ColourRandomizationLevel.absurd:
			return input[0..$].map!(x => x.toHSV).map!(x => HSV(rand.uniform01(), rand.uniform01(), rand.uniform01())).map!(x => x.toRGB!T).array;
		case ColourRandomizationLevel.extreme:
			return input[0..$].map!(x => T(rand.uniform01(), rand.uniform01(), rand.uniform01())).array;
	}
}

void randomizeGamePalettes(Game)(ref GameWrapper!Game game, const uint seed, const Options options) {
	import std.random : Random, uniform;
	import std.stdio : writeln;
	import std.traits : getSymbolsByUDA, getUDAs, hasUDA;

	auto rand = Random(seed);
	uint nextSeed = seed;

	static foreach (field; getSymbolsByUDA!(Game, Palette)) {{
		enum paletteOptions = getUDAs!(field, Palette)[0];
		static if (hasUDA!(field, Label)) {
			enum label = getUDAs!(field, Label)[0];
			writeln("\t- "~label.name~"...");
		}
		debug(verbose) writeln("Randomizing "~field.stringof~"...");
		foreach (ref palette; mixin("game.game."~field.stringof)[]) {
			if (!paletteOptions.shareSeed) {
				nextSeed = rand.uniform!uint;
			}
			size_t start = 1;
			if (paletteOptions.dontSkipFirst) {
				start = 0;
			}
			palette[start .. $] = randomizePalette(palette[start .. $], options.colourRandomizationStyle, nextSeed);
		}
		nextSeed = rand.uniform!uint;
	}}
}
