%option c++ 8bit noyywrap nostack yymore nodefault
%option outfile="StringFormatScanner.C" prefix="zy"
ascii .
whitespace [ ]
backslash [\\]
apos [\']
doublequote [\"]
alphabetic [a-zA-Z]
numeric [0-9]
%%
<INITIAL>"<"|">"|"="|"+"|"-"|"*"|"/"|"&"|"^"|"~"|"_"|"@"|"$"|"%"|":"|"."|"!"|"?"|"#"|","|"("|")" return 1;
<INITIAL>{numeric} return 2;
<INITIAL>{alphabetic} return 3;
<INITIAL>{doublequote} return 4;
<INITIAL>{apos} return 5;
<INITIAL>{backslash} return 6;
<INITIAL>{whitespace} return 7;
<INITIAL>{ascii} return 8;
<INITIAL>\n return 9;
<INITIAL><<EOF>> return 10;
%%
#include "lexer.h"
