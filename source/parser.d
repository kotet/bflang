module parser;

import pegged.grammar;

public import pegged.grammar : ParseTree;

mixin(grammar(`
BFL:
    Compound    < Stmt+
    Stmt    < ((Putc / Push / Assign) ";") / If / While
    Expr    < (Compare / Pop / Getc)

    While   < "while" Parens "{" Compound "}"
    If      < "if" Parens "{" Compound "}"
    Putc    < "putc" Parens
    Getc    < "getc" "(" ")"
    Push    < Identifier ".push" Parens
    Pop     < Identifier ".pop" "(" ")"
    Assign  < Identifier "=" Expr

    Compare < Eq / Term

    Eq      < Term "==" Term

    Term    < Add / Sub / Factor
    Add     < Term "+" Term
    Sub     < Term "-" Term

    Factor  < Mul / Div / Primary
    Mul     < Factor "*" Factor
    Div     < Factor "/" Factor

    Primary < Pop / Getc / Parens / Number / Char / Identifier
    Parens  < "(" Expr ")"

    Char <- :"'" (.) :"'"

    Identifier <- identifier
    Number  < ~([0-9]+)
`));
