module codegen.codegen;

import genir;
import codegen.instructions;

import std.stdio;
import std.conv : text;

alias emit = writefln;

void emitBF(IRGenerator irg)
{
    allocate_variable(irg.voffset).emit();
    initialize_stack(irg.stacknum).emit();
    auto irs = irg.result;
    foreach (ir; irs)
    {
        with (IR.Type) switch (ir.type)
        {
        case GETC:
            emit(set_stack(irg.stacknum) ~ ",");
            break;
        case PUSH_IMM:
            emit(set_stack(irg.stacknum) ~ imm(ir.value, irg.stacknum));
            break;
        case PUSH_VAR:
            push_variable(ir.value, irg.stacknum).emit();
            break;
        case PUTC:
            emit("." ~ destroy_stack(irg.stacknum));
            break;
        case STORE:
            pop_and_store(ir.value, irg.stacknum).emit();
            break;
        case USER_PUSH:
            user_push(ir.value, irg.stacknum).emit();
            break;
        case USER_POP:
            user_pop(ir.value, irg.stacknum).emit();
            break;
        default:
            throw new Exception("Unknown IR.Type: " ~ ir.type.text);
        }
    }
    writeln();
}
