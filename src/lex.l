%{
    int lineno = 1;
    char log_file_name[40]; // output-file name
    int htoi(const char* hex_int);

    
    #include "tnode.hpp"
    #include "splc_log.hpp"
    #include "symbol_table.hpp"
    #include "symbol_node.hpp"
    #include "syntax.hpp"
    #include "string.h"
    #include "stdio.h"


%}
%option noyywrap
%option yylineno noinput nounput
digit       [0-9]
hex_digit   [0-9a-fA-F]
letter      [a-zA-Z]
letter_     {letter}|_
next_line   \n
empty       [ \n\r\t]

dec_int     0|([1-9]{digit}*)    
hex_int     0[xX](0|[1-9a-fA-F]{hex_digit}*)  
float       {dec_int}\.{digit}+
char        '.'
hex_char    '\\x{hex_digit}{hex_digit}'|'\\x(0|[1-9a-fA-F]{hex_digit})'
id          {letter_}({digit}|{letter_})*

dec_int_err0    0{digit}+             
hex_int_err0    0[xX]0{hex_digit}+  
hex_int_err1    0[xX]([g-zG-Z]+{hex_digit}*)* 

float_err0  {digit}*\.{digit}*

char_err0   '\\x{hex_digit}{3,}'
char_err1   ['][\x21-\x26\x28-\xff]*[']

bad_id      {digit}({digit}|{letter_})+

%%
"//".*      { }
[/][*][^*]*[*]+([^*/][^*]*[*]+)*[/]   { } 
"int"|"float"|"char"    { yylval.agg.nd = new_tnode("TYPE", 0, yylineno); return TYPE; }
"struct"    { yylval.agg.nd = new_tnode("STRUCT", 0, yylineno); return STRUCT; }
"if"        { yylval.agg.nd = new_tnode("IF", 0, yylineno); return IF; }
"else"      { yylval.agg.nd = new_tnode("ELSE", 0, yylineno); return ELSE; }
"while"     { yylval.agg.nd = new_tnode("WHILE", 0, yylineno); return WHILE; }
"return"    { yylval.agg.nd = new_tnode("RETURN", 0, yylineno); return RETURN; }
"."         { yylval.agg.nd = new_tnode("DOT", 0, yylineno); return DOT; }
";"         { yylval.agg.nd = new_tnode("SEMI", 0, yylineno); return SEMI; }
","         { yylval.agg.nd = new_tnode("COMMA", 0, yylineno); return COMMA; }
"="         { yylval.agg.nd = new_tnode("ASSIGN", 0, yylineno); return ASSIGN; }
"<"         { yylval.agg.nd = new_tnode("LT",0,yylineno); return LT; }
"<="        { yylval.agg.nd = new_tnode("LE",0,yylineno); return LE; }
">"         { yylval.agg.nd = new_tnode("GT",0,yylineno); return GT; }
">="        { yylval.agg.nd = new_tnode("GE",0,yylineno); return GE; }
"!="        { yylval.agg.nd = new_tnode("NE",0,yylineno); return NE; }
"=="        { yylval.agg.nd = new_tnode("EQ",0,yylineno); return EQ; }
"+"         { yylval.agg.nd = new_tnode("PLUS",0,yylineno); return PLUS; }
"-"         { yylval.agg.nd = new_tnode("MINUS",0,yylineno); return MINUS; }
"*"         { yylval.agg.nd = new_tnode("MUL",0,yylineno); return MUL; }
"/"         { yylval.agg.nd = new_tnode("DIV",0,yylineno); return DIV; }
"&&"        { yylval.agg.nd = new_tnode("AND",0,yylineno); return AND; }
"||"        { yylval.agg.nd = new_tnode("OR",0,yylineno); return OR; }
"!"         { yylval.agg.nd = new_tnode("NOT",0,yylineno); return NOT; }
"("         { yylval.agg.nd = new_tnode("LP",0,yylineno); return LP; }
")"         { yylval.agg.nd = new_tnode("RP",0,yylineno); return RP; }
"["         { yylval.agg.nd = new_tnode("LB",0,yylineno); return LB; }
"]"         { yylval.agg.nd = new_tnode("RB",0,yylineno); return RB; }
"{"         { yylval.agg.nd = new_tnode("LC",0,yylineno); StartScope(); return LC; }
"}"         { yylval.agg.nd = new_tnode("RC",0,yylineno); EndScope(); return RC; }

{dec_int}   { yylval.agg.nd = new_tnode("INT",0,yylineno,atoi(yytext)); return INT; }         
{hex_int}   { yylval.agg.nd = new_tnode("INT",0,yylineno,htoi(yytext)); return INT; }
{float}         { yylval.agg.nd = new_tnode("FLOAT",0,yylineno,atof(yytext)); return FLOAT; }
{char}|{hex_char}   { yylval.agg.nd = new_tnode("CHAR",0,yylineno); return CHAR; }
{id}        { yylval.agg.nd = new_tnode("ID",0,yylineno); return ID; }


{dec_int_err0}   { LogLSErrorTL(0, yylineno, yytext); yylval.agg.nd = new_tnode("INT",0,yylineno,0); return ILLEGAL_TOKEN; /* 0 leading int */}
{hex_int_err0}   { LogLSErrorTL(0, yylineno, yytext); yylval.agg.nd = new_tnode("INT",0,yylineno,0); return ILLEGAL_TOKEN; /* 0 leading int */}
{hex_int_err1}   { LogLSErrorTL(0, yylineno, yytext); yylval.agg.nd = new_tnode("INT",0,yylineno,0); return ILLEGAL_TOKEN; /* not hex digit */}
{float_err0}    { LogLSErrorTL(0, yylineno, yytext); yylval.agg.nd = new_tnode("FLOAT",0,yylineno,0); return ILLEGAL_TOKEN;}
{char_err0}         { LogLSErrorTL(0, yylineno, yytext); yylval.agg.nd = new_tnode("CHAR",0,yylineno); return ILLEGAL_TOKEN;}
{char_err1}         { LogLSErrorTL(0, yylineno, yytext); yylval.agg.nd = new_tnode("CHAR",0,yylineno); return ILLEGAL_TOKEN;}
{bad_id}    { LogLSErrorTL(0, yylineno, yytext); yylval.agg.nd = new_tnode("ID",0,yylineno); return ID; }


{next_line} { lineno += 1; }
{empty}     { }

.           { LogLSErrorTL(0, yylineno, yytext); return ILLEGAL_TOKEN; }

%%

int htoi(const char* hex_int) 
{
    int size = (int) strlen(hex_int);
    // if (size > 10)
    // {
    //     LogLSErrorTL(0, lineno, "too large integer");
    // }

    int res = 0;
    int hexdigit;
    for (int i = 2; i < size; ++i)
    {
        if (hex_int[i] >= '0' && hex_int[i] <= '9') {
            hexdigit = hex_int[i] - '0';
            res = 16 * res + hexdigit;
        }
        if (hex_int[i] >= 'A' && hex_int[i] <= 'F') {
            hexdigit = hex_int[i] - 'A' + 10;
            res = 16 * res + hexdigit;
        }
        if (hex_int[i] >= 'a' && hex_int[i] <= 'f') {
            hexdigit = hex_int[i] - 'a' + 10;
            res = 16 * res + hexdigit;
        }
    }

    return res;
}
