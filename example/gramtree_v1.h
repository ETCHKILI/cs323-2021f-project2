#ifndef PRO2_GRAMTREE_V1_H
#define PRO2_GRAMTREE_V1_H

extern int yylineno;
extern char* yytext;
void yyerror(char *s,...);

/*抽象语法树的结点*/
struct ast
{
    int line; 
    char* name;
    int tag;//1为变量，2为函数，3为常数,4为数组，5为结构体
    struct ast *l;
    struct ast *r;
    char* content;
    char* type;
    float value;
};


struct var
{
    char* name;
    char* type;
    struct var *next;
}*varhead,*vartail;


struct func
{
    int tag;//0表示未定义，1表示定义
    char* name;
    char* type;
    char* rtype;//return type
    int pnum;//形参数个数
    struct func *next;
}*funchead,*functail;
int rpnum;//记录函数实参个数

/*数组符号表的结点*/
struct array
{
    char* name;
    char* type;
    struct array *next;
}*arrayhead,*arraytail;

/*结构体符号表的结点*/
struct struc
{
    char* name;
    char* type;
    struct struc *next;
}*struchead,*structail;

/*=====抽象语法树========================*/
/*构造抽象语法树,变长参数，name:语法单元名字；num:变长参数中语法结点个数*/
struct ast *newast(char* name,int num,...);

/*遍历抽象语法树，level为树的层数*/
void eval(struct ast*,int level);

/*=====变量符号表========================*/
/*建立变量符号表*/
void newvar(int num,...);

/*查找变量是否已经定义,是返回1，否返回0*/
int  existvar(struct ast*tp);

/*查找变量类型*/
char* typevar(struct ast*tp);

/*=================函数符号表==============*/
/*建立函数符号表,flag：1表示变量符号表，2表示函数符号表,num是参数个数*/
void newfunc(int num,...);

/*查找函数是否已经定义,是返回1，否返回0*/
int existfunc(struct ast*tp);

/*查找函数类型*/
char* typefunc(struct ast*tp);

/*查找函数的形参个数*/
int pnumfunc(struct ast*tp);

/*=================数组符号表==============*/
/*建立数组符号表*/
void newarray(int num,...);

/*查找数组是否已经定义,是返回1，否返回0*/
int existarray(struct ast*tp);

/*查找数组类型*/
char* typearray(struct ast*tp);

/*=================结构体符号表==============*/
/*建立结构体符号表*/
void newstruc(int num,...);

/*查找结构体是否已经定义,是返回1，否返回0*/
int existstruc(struct ast*tp);


#endif

