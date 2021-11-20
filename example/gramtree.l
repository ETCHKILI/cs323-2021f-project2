%{
#include "stdio.h"
#include "stdlib.h"
# include "gramtree_v1.h"
#include "syntax.tab.h"
%}
%option yylineno

digit       [0-9]
hex_digit   [0-9a-fA-F]
letter      [a-zA-Z]
letter_     {letter}|_

TYPE int|float
INTEGER 0|([1-9]{digit}*)
FLOAT   {INTEGER}\.{digit}+ 
ID {letter_}({digit}|{letter_})*
SPACE [ \t\r]*
EOL \n
RELOP >|<|>=|<=|==|!=
AERROR .
%%
"//".*      { }
[/][*][^*]*[*]+([^*/][^*]*[*]+)*[/]   { } 
"int"|"float" {yylval.a=newast("TYPE",0,yylineno);return TYPE;}
"struct" {yylval.a=newast("STRUCT",0,yylineno);return STRUCT;}
"return" {yylval.a=newast("RETURN",0,yylineno); return RETURN;}
"if" { yylval.a=newast("IF",0,yylineno);return IF;}
"else" {yylval.a=newast("ELSE",0,yylineno); return ELSE;}
"while" {yylval.a=newast("WHILE",0,yylineno); return WHILE;}
"+" {yylval.a=newast("PLUS",0,yylineno); return PLUS;}
"-" {yylval.a=newast("MINUS",0,yylineno); return MINUS;}
{INTEGER} {yylval.a=newast("INTEGER",0,yylineno); return INTEGER;}
{FLOAT} {yylval.a=newast("FLOAT",0,yylineno); return FLOAT;}
{ID} {yylval.a=newast("ID",0,yylineno); return ID;}
{SPACE} {}
{EOL} {}
";" {yylval.a=newast("SEMI",0,yylineno); return SEMI;}
"," {yylval.a=newast("COMMA",0,yylineno); return COMMA;}
"=" {yylval.a=newast("ASSIGNOP",0,yylineno); return ASSIGNOP;}
{RELOP} {yylval.a=newast("RELOP",0,yylineno); return RELOP;}
"*" {yylval.a=newast("STAR",0,yylineno); return STAR;}
"/" {yylval.a=newast("DIV",0,yylineno); return DIV;}
"&&" {yylval.a=newast("AND",0,yylineno); return AND;}
"||" {yylval.a=newast("OR",0,yylineno); return OR;}
"." {yylval.a=newast("DOT",0,yylineno); return DOT;}
"!" {yylval.a=newast("NOT",0,yylineno); return NOT;}
"(" {yylval.a=newast("LP",0,yylineno); return LP;}
")" {yylval.a=newast("RP",0,yylineno); return RP;}
"[" {yylval.a=newast("LB",0,yylineno); return LB;}
"]" {yylval.a=newast("RB",0,yylineno); return RB;}
"{" {yylval.a=newast("LC",0,yylineno); return LC;}
"}" {yylval.a=newast("RC",0,yylineno); return RC;}
{AERROR} { printf("Error type A at line %d: Mystirious charachter '%s'\n",yylineno,yytext);}

%%
int yywrap()
{
        return 1;
}

