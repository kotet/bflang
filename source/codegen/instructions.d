module codegen.instructions;

import std.range : cycle, repeat, take, array;
import std.conv : text;

auto rep = (char c, size_t n) => repeat(c).take(n).text();

auto allocate_variable = (size_t n) => rep('>', n);

auto initialize_stack(size_t stacknum)
{
    string result = rep('>', stacknum * 2);
    result ~= rep('<', stacknum - 1);
    return result;
}

auto set_stack(size_t stacknum)
{
    string result = rep('>', stacknum);
    result = result ~ "+" ~ result;
    return result;
}

auto destroy_stack(size_t stacknum)
{
    return "[-]" ~ rep('<', stacknum) ~ "-" ~ rep('<', stacknum);
}

auto imm(long x, size_t stacknum)
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
    if (y == 1)
    {
        return rep('+', x);
    }
    else
    {
        string result = rep('>', stacknum);
        result ~= rep('+', y);
        result ~= "[";
        result ~= rep('<', stacknum);
        result ~= rep('+', x / y);
        result ~= rep('>', stacknum);
        result ~= "-]";
        result ~= rep('<', stacknum);
        result ~= rep('+', x % y);
        return result;
    }
}

auto goto_base(size_t stacknum)
{
    string result;
    result ~= rep('<', stacknum);
    result ~= "[";
    result ~= rep('<', stacknum * 2);
    result ~= "]<";
    return result;
}

auto goto_stacktop(size_t stacknum)
{
    string result = ">";
    result ~= rep('>', stacknum * 2);
    result ~= "[";
    result ~= rep('>', stacknum * 2);
    result ~= "]";
    result ~= rep('<', stacknum);
    return result;
}

auto copy_stacktop(size_t stacknum)
{
    string result;
    result ~= "[";
    result ~= rep('>', stacknum);
    result ~= "+";
    result ~= rep('>', stacknum);
    result ~= "+";
    result ~= rep('<', stacknum * 2);
    result ~= "-]";

    result ~= rep('>', stacknum);
    result ~= "[";
    result ~= rep('<', stacknum);
    result ~= "+";
    result ~= rep('>', stacknum);
    result ~= "-]+";
    result ~= rep('>', stacknum);

    return result;
}

auto pop_and_store(size_t n, size_t stacknum)
{
    string result;
    result ~= "[";
    result ~= goto_base(stacknum);
    result ~= rep('<', n);
    result ~= "+";
    result ~= rep('>', n);
    result ~= goto_stacktop(stacknum);
    result ~= "-]";
    result ~= rep('<', stacknum);
    result ~= "-";
    result ~= rep('<', stacknum);
    return result;
}

auto push_variable(size_t n, size_t stacknum)
{
    string result = set_stack(stacknum) ~ goto_base(stacknum);
    string lshift = rep('<', n);
    string rshift = rep('>', n);

    result ~= lshift ~ "[" ~ rshift;
    result ~= goto_stacktop(stacknum);
    result ~= "+";
    result ~= goto_base(stacknum);
    result ~= lshift ~ "-]>";
    result ~= goto_stacktop(stacknum) ~ copy_stacktop(stacknum);
    result ~= pop_and_store(n, stacknum);

    return result;
}

auto user_push(long n, size_t stacknum)
{
    string result;
    result ~= goto_base(stacknum);
    result ~= rep('>', n - 1);
    result ~= goto_stacktop(stacknum);
    result ~= set_stack(stacknum);
    result ~= goto_base(stacknum);
    result ~= rep('<', n - 1);
    result ~= goto_stacktop(stacknum);

    result ~= "[";
    result ~= goto_base(stacknum);
    result ~= rep('>', n - 1);
    result ~= goto_stacktop(stacknum);
    result ~= "+";
    result ~= goto_base(stacknum);
    result ~= rep('<', n - 1);
    result ~= goto_stacktop(stacknum);
    result ~= "-]";

    result ~= destroy_stack(stacknum);
    return result;
}

auto user_pop(long n, size_t stacknum)
{
    string result;
    result ~= set_stack(stacknum);
    result ~= goto_base(stacknum);
    result ~= rep('>', n - 1);
    result ~= goto_stacktop(stacknum);

    result ~= "[";
    result ~= goto_base(stacknum);
    result ~= rep('<', n - 1);
    result ~= goto_stacktop(stacknum);
    result ~= "+";
    result ~= goto_base(stacknum);
    result ~= rep('>', n - 1);
    result ~= goto_stacktop(stacknum);
    result ~= "-]";

    result ~= destroy_stack(stacknum);
    result ~= goto_base(stacknum);
    result ~= rep('<', n - 1);
    result ~= goto_stacktop(stacknum);
    return result;
}

auto add(size_t stacknum)
{
    string result;
    result ~= "[";
    result ~= rep('<', stacknum * 2);
    result ~= "+";
    result ~= rep('>', stacknum * 2);
    result ~= "-]";
    result ~= rep('<', stacknum);
    result ~= "-";
    result ~= rep('<', stacknum);
    return result;
}

auto sub(size_t stacknum)
{
    string result;
    result ~= "[";
    result ~= rep('<', stacknum * 2);
    result ~= "-";
    result ~= rep('>', stacknum * 2);
    result ~= "-]";
    result ~= rep('<', stacknum);
    result ~= "-";
    result ~= rep('<', stacknum);
    return result;
}

auto mul(size_t stacknum)
{
    string result;
    result ~= "[";
    result ~= rep('<', stacknum * 2);
    result ~= "[";
    result ~= rep('>', stacknum * 3);
    result ~= "+";
    result ~= rep('>', stacknum);
    result ~= "+";
    result ~= rep('<', stacknum * 4);
    result ~= "-]";
    result ~= rep('>', stacknum * 3);
    result ~= "[";
    result ~= rep('<', stacknum * 3);
    result ~= "+";
    result ~= rep('>', stacknum * 3);
    result ~= "-]";
    result ~= rep('<', stacknum);
    result ~= "-]";

    result ~= rep('<', stacknum * 2);
    result ~= "[-]";

    result ~= rep('>', stacknum * 4);
    result ~= "[";
    result ~= rep('<', stacknum * 4);
    result ~= "+";
    result ~= rep('>', stacknum * 4);
    result ~= "-]";

    result ~= rep('<', stacknum * 3);
    result ~= "-";
    result ~= rep('<', stacknum);

    return result;
}

