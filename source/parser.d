module parser;

import pegged.grammar;

public import pegged.grammar : ParseTree;

mixin(grammar(`
BFL:
    Comp    < Stmt+
    Stmt    < (Putc / Assign) ";"
    Expr    < (Getc / Term)
    
    Putc    < "putc" Parens
    Getc    < "getc" "(" ")"
    Assign  < Identifier "=" Expr

    Term    < Add / Sub / Factor
    Add     < Term "+" Term
    Sub     < Term "-" Term

    Factor  < Mul / Div / Primary
    Mul     < Factor "*" Factor
    Div     < Factor "/" Factor

    Primary < Getc / Parens / Number / Char / Identifier
    Parens  < "(" Term ")"

    Char <- :"'" (.) :"'"

    Identifier <- identifier
    Number  < ~([0-9]+)
`));
