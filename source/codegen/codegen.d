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
            emit(push_variable(ir.value, irg.stacknum));
            break;
        case PUTC:
            emit("." ~ destroy_stack(irg.stacknum));
            break;
        case STORE:
            emit(pop_and_store(ir.value, irg.stacknum));
            break;
        case USER_PUSH:
            emit(user_push(ir.value, irg.stacknum));
            break;
        case USER_POP:
            emit(user_pop(ir.value, irg.stacknum));
            break;
        case ADD:
            emit(add(irg.stacknum));
            break;
        case SUB:
            emit(sub(irg.stacknum));
            break;
        case MUL:
            emit(mul(irg.stacknum));
            break;
        case IF:
            "[".emit();
            break;
        case ENDIF:
            ("[-]]" ~ destroy_stack(irg.stacknum)).emit();
            break;
        case WHILE:
            emit("[" ~ destroy_stack(irg.stacknum));
            break;
        case ENDWHILE:
            emit("]" ~ destroy_stack(irg.stacknum));
            break;
        case EQ:
            emit(sub(irg.stacknum) ~ is_zero(irg.stacknum));
            break;
        default:
            throw new Exception("Unknown IR.Type: " ~ ir.type.text);
        }
    }
    writeln();
}
