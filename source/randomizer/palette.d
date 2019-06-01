module randomizer.palette;

import libgamestruct.common;
import pixelatrix.color;
import std.random : Random, uniform;

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
			return input.map!(x => x.toHSV).map!(x => HSV((x.hue + randomConstant) % 1.0, x.saturation, x.value)).map!(x => x.toRGB!T).array;
		case ColourRandomizationLevel.multHue:
			return input.map!(x => x.toHSV).map!(x => HSV((x.hue * randomConstant * 2.0) % 1.0, x.saturation, x.value)).map!(x => x.toRGB!T).array;
		case ColourRandomizationLevel.randomHue:
			return input.map!(x => x.toHSV).map!(x => HSV(rand.uniform01(), x.saturation, x.value)).map!(x => x.toRGB!T).array;
		case ColourRandomizationLevel.randomSaturation:
			return input.map!(x => x.toHSV).map!(x => HSV(x.hue, rand.uniform01(), x.value)).map!(x => x.toRGB!T).array;
		case ColourRandomizationLevel.shiftSaturation:
			return input.map!(x => x.toHSV).map!(x => HSV(x.hue, (x.saturation + randomConstant) % 1.0, x.value)).map!(x => x.toRGB!T).array;
		case ColourRandomizationLevel.multSaturation:
			return input.map!(x => x.toHSV).map!(x => HSV(x.hue, min(x.saturation * randomConstant * 2.0, 1.0), x.value)).map!(x => x.toRGB!T).array;
		case ColourRandomizationLevel.randomValue:
			return input.map!(x => x.toHSV).map!(x => HSV(x.hue, x.saturation, rand.uniform01())).map!(x => x.toRGB!T).array;
		case ColourRandomizationLevel.shiftValue:
			return input.map!(x => x.toHSV).map!(x => HSV(x.hue, x.saturation, (x.value + randomConstant) % 1.0)).map!(x => x.toRGB!T).array;
		case ColourRandomizationLevel.multValue:
			return input.map!(x => x.toHSV).map!(x => HSV(x.hue, x.saturation, min(x.value * randomConstant * 2.0, 1.0))).map!(x => x.toRGB!T).array;
		case ColourRandomizationLevel.absurd:
			return input.map!(x => x.toHSV).map!(x => HSV(rand.uniform01(), rand.uniform01(), rand.uniform01())).map!(x => x.toRGB!T).array;
		case ColourRandomizationLevel.extreme:
			return input.map!(x => T(rand.uniform01(), rand.uniform01(), rand.uniform01())).array;
	}
}

void randomizePalette(Palette paletteOptions, T)(ref T field, ref Random rng, ref uint seed, const Options options) {
	if (!paletteOptions.shareSeed) {
		seed = rng.uniform!uint;
	}
	size_t start = 1;
	if (paletteOptions.dontSkipFirst) {
		start = 0;
	}
	field[start .. $] = randomizePalette(field[start .. $], options.colourRandomizationStyle, seed);
}

void randomizeGamePalettes(Game)(ref Game game, const uint seed, const Options options) {
	randomizeBase!(Palette, randomizePalette)(game, seed, options);
}
