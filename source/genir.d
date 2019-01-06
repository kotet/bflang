module genir;

import parser;

import std.stdio : writeln;
import std.conv : to;
import std.string : chomp;

struct IR
{
    Type type;
    long value;
    enum Type
    {
        PUTC,
        GETC,
        PUSH_IMM,
        PUSH_VAR,
        STORE,
    }

    this(Type type, long value)
    {
        this.type = type;
        this.value = value;
    }
}

size_t[string] vars;
size_t offset = 0;

size_t getVariableOffset()
{
    return offset;
}

IR[] generateIR(ParseTree tree)
{
    IR[] result;
    void genIR(ParseTree tree)
    {
        switch (tree.name)
        {
        case "BFL":
        case "BFL.Expr":
        case "BFL.Parens":
        case "BFL.Term":
        case "BFL.Factor":
        case "BFL.Primary":
        case "BFL.Stmt":
            assert(tree.children.length == 1);
            genIR(tree.children[0]);
            return;
        case "BFL.Comp":
            foreach (subtree; tree.children)
                genIR(subtree);
            return;
        case "BFL.Putc":
            assert(tree.children.length == 1);
            genIR(tree.children[0]);
            result ~= IR(IR.Type.PUTC, -1);
            return;
        case "BFL.Getc":
            result ~= IR(IR.Type.GETC, -1);
            return;
        case "BFL.Number":
            string s = tree.matches[0];
            result ~= IR(IR.Type.PUSH_IMM, s.to!long());
            return;
        case "BFL.Char":
            char c = tree.matches[0][0];
            result ~= IR(IR.Type.PUSH_IMM, cast(long) c);
            return;
        case "BFL.Assign":
            auto ident = tree.children[0];
            assert(ident.name == "BFL.Identifier");
            string s = ident.matches[0];
            vars[s] = ++offset;
            assert(tree.children[1].name == "BFL.Expr");
            genIR(tree.children[1]);
            result ~= IR(IR.Type.STORE, vars[s]);
            break;
        case "BFL.Identifier":
            string s = tree.matches[0];
            // writeln(s, vars);
            result ~= IR(IR.Type.PUSH_VAR, vars[s]);
            break;
        default:
            throw new Exception("Unknown Node: " ~ tree.name);
        }
    }

    genIR(tree);
    return result;
}
