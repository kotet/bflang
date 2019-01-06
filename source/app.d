import std.stdio;

import parser;
import genir;
import codegen;

void main(string[] args)
{
	if (args.length != 2)
	{
		stderr.writeln("Usage: bflang \"<code>\"");
		return;
	}
	ParseTree tree = BFL(args[1]);
	// stderr.writeln(tree);

	if (tree.end != args[1].length)
	{
		stderr.writefln!"Parser error: %d - %d"(tree.end, args[1].length);
		stderr.writeln(args[1][tree.end .. $]);
		return;
	}

	IR[] irs = tree.generateIR();
	// stderr.writeln(irs);

	emitBF(irs, getVariableOffset());
}
