module rando.palette;

import libgamestruct.common;
import magicalrainbows.formats;
import std.random : Random, uniform;

import rando.common;

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

T[] randomizePalette(T)(T[] input, ColourRandomizationLevel randomizationLevel, uint seed) {
	import std.algorithm.iteration : map;
	import std.algorithm.comparison : min;
	import std.array : array;
	import std.random : Random, uniform01;

	auto rand = Random(seed);
	const randomConstant = rand.uniform01();
	HSVA!float genRandomHSV(HSVA!float input, ColourRandomizationLevel level) {
		final switch (randomizationLevel) {
			case ColourRandomizationLevel.shiftHue:
				return HSVA!float(
					(input.hue + randomConstant) % 1.0,
					input.saturation,
					input.value,
					input.alpha
				);
			case ColourRandomizationLevel.multHue:
				return HSVA!float(
					(input.hue * randomConstant * 2.0) % 1.0,
					input.saturation,
					input.value,
					input.alpha
				);
			case ColourRandomizationLevel.randomHue:
				return HSVA!float(
					rand.uniform01(),
					input.saturation,
					input.value,
					input.alpha
				);
			case ColourRandomizationLevel.randomSaturation:
				return HSVA!float(
					input.hue,
					rand.uniform01(),
					input.value,
					input.alpha
				);
			case ColourRandomizationLevel.shiftSaturation:
				return HSVA!float(
					input.hue,
					(input.saturation + randomConstant) % 1.0,
					input.value,
					input.alpha
				);
			case ColourRandomizationLevel.multSaturation:
				return HSVA!float(
					input.hue,
					min(input.saturation * randomConstant * 2.0, 1.0),
					input.value,
					input.alpha
				);
			case ColourRandomizationLevel.randomValue:
				return HSVA!float(
					input.hue,
					input.saturation,
					rand.uniform01(),
					input.alpha
				);
			case ColourRandomizationLevel.shiftValue:
				return HSVA!float(
					input.hue,
					input.saturation,
					(input.value + randomConstant) % 1.0,
					input.alpha
				);
			case ColourRandomizationLevel.multValue:
				return HSVA!float(
					input.hue,
					input.saturation,
					min(input.value * randomConstant * 2.0, 1.0),
					input.alpha
				);
			case ColourRandomizationLevel.absurd:
				return HSVA!float(
					rand.uniform01(),
					rand.uniform01(),
					rand.uniform01(),
					input.alpha
				);
			case ColourRandomizationLevel.extreme:
				return RGB888(
					rand.uniform!ubyte(),
					rand.uniform!ubyte(),
					rand.uniform!ubyte()
				).toHSVA!float;
		}
	}
	return input.map!(x => x.toHSVA!float).map!(x => genRandomHSV(x, randomizationLevel)).map!(x => x.toRGB!(T, float)).array;
}

void randomizePalette(Palette paletteOptions, T)(ref T field, ref Random rng, ref uint seed, const Options options) {
	if (!paletteOptions.shareSeed) {
		seed = rng.uniform!uint;
	}
	const start = paletteOptions.dontSkipFirst ? 0 : 1;
	field[start .. $] = randomizePalette(field[start .. $], options.colourRandomizationStyle, seed);
}
