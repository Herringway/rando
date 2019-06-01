module rando.palette;

import libgamestruct.common;
import pixelatrix.color;
import std.random : Random, uniform;

import rando.common;

T[] randomizePalette(T)(T[] input, ColourRandomizationLevel randomizationLevel, uint seed) {
	import std.algorithm.iteration : map;
	import std.algorithm.comparison : min;
	import std.array : array;
	import std.random : Random, uniform01;

	auto rand = Random(seed);
	const randomConstant = rand.uniform01();
	HSV genRandomHSV(HSV input, ColourRandomizationLevel level) {
		final switch (randomizationLevel) {
			case ColourRandomizationLevel.shiftHue:
				return HSV(
					(input.hue + randomConstant) % 1.0,
					input.saturation,
					input.value
				);
			case ColourRandomizationLevel.multHue:
				return HSV((
					input.hue * randomConstant * 2.0) % 1.0,
					input.saturation,
					input.value
				);
			case ColourRandomizationLevel.randomHue:
				return HSV(
					rand.uniform01(),
					input.saturation,
					input.value
				);
			case ColourRandomizationLevel.randomSaturation:
				return HSV(
					input.hue,
					rand.uniform01(),
					input.value
				);
			case ColourRandomizationLevel.shiftSaturation:
				return HSV(
					input.hue,
					(input.saturation + randomConstant) % 1.0,
					input.value
				);
			case ColourRandomizationLevel.multSaturation:
				return HSV(
					input.hue,
					min(input.saturation * randomConstant * 2.0, 1.0),
					input.value
				);
			case ColourRandomizationLevel.randomValue:
				return HSV(
					input.hue,
					input.saturation,
					rand.uniform01()
				);
			case ColourRandomizationLevel.shiftValue:
				return HSV(
					input.hue,
					input.saturation,
					(input.value + randomConstant) % 1.0
				);
			case ColourRandomizationLevel.multValue:
				return HSV(
					input.hue,
					input.saturation,
					min(input.value * randomConstant * 2.0, 1.0)
				);
			case ColourRandomizationLevel.absurd:
				return HSV(
					rand.uniform01(),
					rand.uniform01(),
					rand.uniform01()
				);
			case ColourRandomizationLevel.extreme:
				return T(
					rand.uniform01(),
					rand.uniform01(),
					rand.uniform01()
				).toHSV;
		}
	}
	return input.map!(x => x.toHSV).map!(x => genRandomHSV(x, randomizationLevel)).map!(x => x.toRGB!T).array;
}

void randomizePalette(Palette paletteOptions, T)(ref T field, ref Random rng, ref uint seed, const Options options) {
	if (!paletteOptions.shareSeed) {
		seed = rng.uniform!uint;
	}
	const start = paletteOptions.dontSkipFirst ? 0 : 1;
	field[start .. $] = randomizePalette(field[start .. $], options.colourRandomizationStyle, seed);
}

void randomizeGamePalettes(Game)(ref Game game, const uint seed, const Options options) {
	randomizeBase!(Palette, randomizePalette)(game, seed, options);
}
