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
        USER_PUSH,
        USER_POP,
        ADD,
        SUB,
        MUL,
        DIV,
    }

    this(Type type, long value)
    {
        this.type = type;
        this.value = value;
    }
}

class IRGenerator
{
    size_t[string] vars;
    size_t[string] stacks;
    size_t voffset = 0;
    size_t stacknum = 1;
    IR[] result;

    this()
    {

    }

    void generateIR(ParseTree tree)
    {
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
                if (s !in vars)
                {
                    vars[s] = ++voffset;
                }
                assert(tree.children[1].name == "BFL.Expr");
                genIR(tree.children[1]);
                result ~= IR(IR.Type.STORE, vars[s]);
                break;
            case "BFL.Identifier":
                string s = tree.matches[0];
                // writeln(s, vars);
                result ~= IR(IR.Type.PUSH_VAR, vars[s]);
                break;
            case "BFL.Push":
                auto s = tree.children[0].matches[0];
                if (s !in stacks)
                {
                    stacks[s] = ++stacknum;
                }
                genIR(tree.children[1]);
                result ~= IR(IR.Type.USER_PUSH, stacks[s]);
                break;
            case "BFL.Pop":
                auto s = tree.children[0].matches[0];
                result ~= IR(IR.Type.USER_POP, stacks[s]);
                break;
            case "BFL.Add":
                genIR(tree.children[0]);
                genIR(tree.children[1]);
                result ~= IR(IR.Type.ADD, -1);
                return;
            case "BFL.Sub":
                genIR(tree.children[0]);
                genIR(tree.children[1]);
                result ~= IR(IR.Type.SUB, -1);
                return;
            case "BFL.Mul":
                genIR(tree.children[0]);
                genIR(tree.children[1]);
                result ~= IR(IR.Type.MUL, -1);
                return;
            case "BFL.Div":
                genIR(tree.children[0]);
                genIR(tree.children[1]);
                result ~= IR(IR.Type.DIV, -1);
                return;
            default:
                throw new Exception("Unknown Node: " ~ tree.name);
            }
        }

        genIR(tree);
    }
}
