module randomizer.app;

import std.conv;
import std.file;
import std.getopt;
import std.meta;
import std.random;
import std.stdio : writeln;
import std.traits;

import randomizer.common;
import randomizer.palette;

import libgamestruct;

void main(string[] args) {
	Options options;
	  auto helpInformation = getopt(
	    args,
	    "colourstyle|c",  "Colour randomization mode: shiftHue, randomHue, shiftSaturation, randomSaturation, shiftValue, randomValue, absurd, extreme", &options.colourRandomizationStyle,
	    "seed|s",  "A seed value between 0 and 4294967295", ((string o, string s) => options.seed = s.to!uint)
    );
	  if (helpInformation.helpWanted || (args.length < 2)) {
	    defaultGetoptPrinter("Usage: randomizer <path to game>.", helpInformation.options);
	  }
	if (args.length > 1) {
		ubyte[] data = cast(ubyte[])read(args[1]);
		const seed = options.seed.isNull ? unpredictableSeed : options.seed;
		static foreach (Game; AliasSeq!(MMBN1, MMBN2, MMBN3, MMBN4, MMBN5, MMBN6, Earthbound, PokemonGS)) {
			randomizeGame!Game(data, seed, options);
		}
	}
}

void randomizeGame(Game)(ubyte[] data, const uint seed, const Options options) {
	if (data.length < GameWrapper!Game.minimumSize) {
		debug(verbose) writeln("Data too small for "~Game.stringof);
		return;
	}
	auto game = GameWrapper!Game(data);
	if (!game.verify()) {
		debug(verbose) writeln("Data failed verification for "~Game.stringof);
		return;
	}
	writeln("Loaded game: ", game.name);
	auto rand = Random(seed);
	auto nextSeed = rand.uniform!uint;
	writeln("Random seed: ", seed);
	writeln("Randomizing palettes...");
	randomizeGamePalettes(game, nextSeed, options);
	auto filename = game.name~"."~seed.text~"."~Game.extension;
	writeln("Writing "~filename~"...");
	write(filename, game.raw);
}
