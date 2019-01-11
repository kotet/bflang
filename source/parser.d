module parser;

import pegged.grammar;

public import pegged.grammar : ParseTree;

mixin(grammar(`
BFL:
    Comp    < Stmt+
    Stmt    < ((Putc / Push / Assign) ";") / If
    Expr    < (Term / Pop / Getc)
    
    If      < "if" Parens "{" Stmt "}"
    Putc    < "putc" Parens
    Getc    < "getc" "(" ")"
    Push    < Identifier ".push" Parens
    Pop     < Identifier ".pop" "(" ")"
    Assign  < Identifier "=" Expr

    Term    < Add / Sub / Factor
    Add     < Term "+" Term
    Sub     < Term "-" Term

    Factor  < Mul / Div / Primary
    Mul     < Factor "*" Factor
    Div     < Factor "/" Factor

    Primary < Getc / Parens / Number / Char / Identifier
    Parens  < "(" Expr ")"

    Char <- :"'" (.) :"'"

    Identifier <- identifier
    Number  < ~([0-9]+)
`));
