module codegen;

import genir;

import std.stdio;
import std.range : repeat, take, array;
import std.conv : text;

alias emit = writef;

void emitBF(IR[] irs, size_t offset)
{
    repeat('>').take(offset).text.emit(); // allocation
    emit(">>+>"); // initalize stack
    foreach (ir; irs)
    {
        with (IR.Type) switch (ir.type)
        {
        case GETC:
            emit(">+>,");
            break;
        case PUSH_IMM:
            emit(">+>");
            optimizeIMM(ir.value).emit();
            break;
        case PUSH_VAR:
            string lshift = repeat('<').take(ir.value).text;
            string rshift = repeat('>').take(ir.value).text;
            emit(">+>");
            emit!">+[<<]%s[%s>>[>>]<+<<+<[<<]%s-]"(lshift, rshift, lshift);
            emit!"%s>>[>>]<"(rshift);
            emit!"[<<<[<<]%s+%r>>[>>]<-]<-<"(lshift, rshift);
            break;
        case PUTC:
            emit(".[-]<-<");
            break;
        case STORE:
            string lshift = repeat('<').take(ir.value).text;
            string rshift = repeat('>').take(ir.value).text;
            emit!"[<[<<]%s+%s>>[>>]<-]<-<"(lshift, rshift);
            break;
        default:
            throw new Exception("Unknown IR.Type: " ~ ir.type.text);
        }
    }
    writeln();
}

string optimizeIMM(long x)
{
    x %= 256;
    long y = 1;
    long m = x;
    foreach (n; 1 .. 256)
    {
        long len = n + (x / n) + (x % n) + 6;
        if (len < m)
        {
            m = len;
            y = n;
        }
    }
    auto r = repeat('+');
    if (y == 1)
    {
        return r.take(x).text;
    }
    else
    {
        return ">" ~ r.take(y).text ~ "[<" ~ r.take(x / y).text ~ ">-]<" ~ r.take(x % y).text;
    }
}
