import std.stdio;
import std.file;
import std.string;

import parser;
import genir;
import codegen;

void main(string[] args)
{
	if (args.length != 2)
	{
		stderr.writeln("Usage: bflang \"<filename>\"");
		return;
	}
	string input = readText(args[1]).chomp();

	ParseTree tree = BFL(input);
	stderr.writeln(tree);

	if (tree.end != input.length)
	{
		stderr.writefln!"Parser error: %d - %d"(tree.end, input.length);
		stderr.writeln(input[tree.end .. $]);
		return;
	}

	auto irg = new IRGenerator();
	irg.generateIR(tree);

	// stderr.writeln(irg.result);

	emitBF(irg);
}
