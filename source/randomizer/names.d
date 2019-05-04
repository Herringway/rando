module randomizer.names;

import libgamestruct.common;

import randomizer.common;

static immutable string[string] genTable;
static immutable string[string] genTableStarts;

enum minNameLength = 3;

shared static this() {
	import std.uni : isUpper;
	string[string] tableUpper;
	string[string] tableLower;
	genTableStarts = createTable!true(import("nametable.txt"));
	genTable = createTable!false(import("nametable.txt"));
	import std.stdio;
}

string[string] createTable(bool upper)(string data) @safe {
	import std.algorithm.iteration : splitter;
	import std.array : front;
	import std.string : lineSplitter;
	import std.uni : isUpper, toLower;
	string[string] result;
	foreach (line; data.lineSplitter()) {
		auto split = line.splitter(" ");
		string key = split.front;
		if (upper) {
			if (!key.front.isUpper) {
				continue;
			}
		} else {
			key = key.toLower();
		}
		split.popFront();
		result[key] = split.front;
	}
	return result;
}

string generateName(size_t length, uint seed) @safe
	in(length >= minNameLength, "Length must be at least "~('0'+minNameLength))
{
	import std.random : Random, uniform;
	import std.uni : toLower;
	string pickRandomKey(immutable string[string] assoc, ref Random rnd) @trusted {
		return assoc.keys[uniform(0, assoc.length, rnd)];
	}

	auto rand = Random(seed);
	string result = pickRandomKey(genTableStarts, rand);
	result.reserve(length);
	while (result.length < length) {
		auto lastChars = result[$-3 .. $].toLower();
		if (lastChars !in genTable) {
			if (result.length < length - 4) {
				result ~= ' '~pickRandomKey(genTableStarts, rand);
			} else {
				return result;
			}
		} else {
			result ~= genTable[lastChars][uniform(0, genTable[lastChars].length, rand)];
		}
	}
	return result;
}


void randomizeGameNames(Game)(ref GameWrapper!Game game, const uint seed, const Options options) {
	import std.random : Random, uniform;
	import std.stdio : writeln;
	import std.traits : getSymbolsByUDA, getUDAs, hasUDA;

	auto rand = Random(seed);
	uint nextSeed = seed;

	static foreach (field; getSymbolsByUDA!(Game, Name)) {{
		enum nameOptions = getUDAs!(field, Name)[0];
		static if (hasUDA!(field, Label)) {
			enum label = getUDAs!(field, Label)[0];
			writeln("\t- "~label.name~"...");
		}
		debug(verbose) writeln("Randomizing "~field.stringof~"...");
		foreach (ref name; mixin("game.game."~field.stringof)[]) {
			nextSeed = rand.uniform!uint;
			name = generateName(name.length, nextSeed);
		}
		nextSeed = rand.uniform!uint;
	}}
}
