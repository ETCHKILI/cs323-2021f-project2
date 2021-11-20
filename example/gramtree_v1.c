# include<stdio.h>
# include<stdlib.h>
# include<stdarg.h>
# include"gramtree_v1.h"
#include "syntax.tab.c"

int i;
struct ast *newast(char* name,int num,...)
{
    va_list valist; 
    struct ast *a=(struct ast*)malloc(sizeof(struct ast));
    struct ast *temp=(struct ast*)malloc(sizeof(struct ast));
    if(!a)
    {
        yyerror("out of space");
        exit(0);
    }
    a->name=name;
    va_start(valist,num);

    if(num>0)
    {
        temp=va_arg(valist, struct ast*);
        a->l=temp;
        a->line=temp->line;
        if(num==1)
        {
            a->content=temp->content;
            a->tag=temp->tag;
        }
        else 
        {
            for(i=0; i<num-1; ++i)
            {
                temp->r=va_arg(valist,struct ast*);
                temp=temp->r;
            }
        }
    }
    else 
    {
        int t=va_arg(valist, int); 
        a->line=t;
        if(!strcmp(a->name,"INTEGER"))
        {
            a->type="int";
            a->value=atoi(yytext);
        }
        else if(!strcmp(a->name,"FLOAT"))
        {
            a->type="float";
            a->value=atof(yytext);
        }
        else
        {
            char* s;
            s=(char*)malloc(sizeof(char* )*40);
            strcpy(s,yytext);//存储词法单元的语义值
            a->content=s;
        }
    }
    return a;
}
void eval(struct ast *a,int level)
{
    if(a!=NULL)
    {
        for(i=0; i<level; ++i)
            printf("  ");
        if(a->line!=-1)  
        {
            printf("%s ",a->name);
            if((!strcmp(a->name,"ID"))||(!strcmp(a->name,"TYPE")))printf(":%s ",a->content);
            else if(!strcmp(a->name,"INTEGER"))printf(":%s",a->type);
            else
                printf("(%d)",a->line);
        }
        printf("\n");
        eval(a->l,level+1);
        eval(a->r,level);
    }
}

/*====(1)变量符号表的建立和查询================*/
void newvar(int num,...)
{
    va_list valist; 
    struct var *a=(struct var*)malloc(sizeof(struct var));
    struct ast *temp=(struct ast*)malloc(sizeof(struct ast));
    va_start(valist,num);
    temp=va_arg(valist, struct ast*);
    a->type=temp->content;
    temp=va_arg(valist, struct ast*);
    a->name=temp->content;
    vartail->next=a;
    vartail=a;
}

int  existvar(struct ast* tp)//2)查找变量是否已经定义,是1，否0
{
    struct var* p=(struct var*)malloc(sizeof(struct var*));
    p=varhead->next;
    int flag=0;
    while(p!=NULL)
    {
        if(!strcmp(p->name,tp->content))
        {
            flag=1;    
            return 1;
        }
        p=p->next;
    }
    if(!flag)
    {
        return 0;
    }
}

char* typevar(struct ast*tp)
{
    struct var* p=(struct var*)malloc(sizeof(struct var*));
    p=varhead->next;
    while(p!=NULL)
    {
        if(!strcmp(p->name,tp->content))
            return p->type;//返回变量类型
        p=p->next;
    }
}

/*====(2)函数符号表的建立和查询================*/
void newfunc(int num,...)
{
    va_list valist; 
    struct ast *temp=(struct ast*)malloc(sizeof(struct ast));
    va_start(valist,num);
    switch(num)
    {
    case 1:
        functail->pnum+=1;
        break;
    case 2:
        temp=va_arg(valist, struct ast*);
        functail->name=temp->content;
        break;
    case 3:
        temp=va_arg(valist, struct ast*);
        functail->rtype=temp->type;
        break;
    default:
        rpnum=0;
        temp=va_arg(valist, struct ast*);
        if(functail->rtype!=NULL)
        {
            if(strcmp(temp->content,functail->rtype))printf("Error type 8 at Line %d:Type mismatched for return.\n",yylineno);
        }
        functail->type=temp->type;
        functail->tag=1;
        struct func *a=(struct func*)malloc(sizeof(struct func));
        functail->next=a;//尾指针指向下一个空结点
        functail=a;
        break;
    }
}

int  existfunc(struct ast* tp)//2)查找函数是否已经定义,是1，否0
{
    int flag=0;
    struct func* p=(struct func*)malloc(sizeof(struct func*));
    p=funchead->next;
    while(p!=NULL&&p->name!=NULL&&p->tag==1)
    {
        if(!strcmp(p->name,tp->content))
        {
            flag=1;    
            return 1;
        }
        p=p->next;
    }
    if(!flag)
        return 0;
}
char* typefunc(struct ast*tp)
{
    struct func* p=(struct func*)malloc(sizeof(struct func*));
    p=funchead->next;
    while(p!=NULL)
    {
        if(!strcmp(p->name,tp->content))
            return p->type;
        p=p->next;
    }
}

int pnumfunc(struct ast*tp)
{
    struct func* p=(struct func*)malloc(sizeof(struct func*));
    p=funchead->next;
    while(p!=NULL)
    {
        if(!strcmp(p->name,tp->content))
            return p->pnum;
        p=p->next;
    }
}

/*====(3)数组符号表的建立和查询================*/
void newarray(int num,...)
{
    va_list valist; 
    struct array *a=(struct array*)malloc(sizeof(struct array));
    struct ast *temp=(struct ast*)malloc(sizeof(struct ast));
    va_start(valist,num);
    temp=va_arg(valist, struct ast*);
    a->type=temp->content;
    temp=va_arg(valist, struct ast*);
    a->name=temp->content;
    arraytail->next=a;
    arraytail=a;
}

int  existarray(struct ast* tp)//2)查找数组是否已经定义,是1，否0
{
    struct array* p=(struct array*)malloc(sizeof(struct array*));
    p=arrayhead->next;
    int flag=0;
    while(p!=NULL)
    {
        if(!strcmp(p->name,tp->content))
        {
            flag=1;   
            return 1;
        }
        p=p->next;
    }
    if(!flag)
    {
        return 0;
    }
}

char* typearray(struct ast* tp)//3)查找数组类型
{
    struct array* p=(struct array*)malloc(sizeof(struct array*));
    p=arrayhead->next;
    while(p!=NULL)
    {
        if(!strcmp(p->name,tp->content))
            return p->type;//返回数组类型
        p=p->next;
    }
}

/*====(4)结构体符号表的建立和查询================*/
void newstruc(int num,...)
{
    va_list valist; 
    struct struc *a=(struct struc*)malloc(sizeof(struct struc));
    struct ast *temp=(struct ast*)malloc(sizeof(struct ast));
    va_start(valist,num);
    temp=va_arg(valist, struct ast*);
    a->name=temp->content;
    structail->next=a;
    structail=a;
}

int  existstruc(struct ast* tp)//2)查找结构体是否已经定义,是1，否0
{
    struct struc* p=(struct struc*)malloc(sizeof(struct struc*));
    p=struchead->next;
    int flag=0;
    while(p!=NULL)
    {
        if(!strcmp(p->name,tp->content))
        {
            flag=1;  
            return 1;
        }
        p=p->next;
    }
    if(!flag)
    {
        return 0;
    }
}

void yyerror(char*s,...) //变长参数错误处理函数
{
    va_list ap;
    va_start(ap,s);
    fprintf(stderr,"%d:error:",yylineno);//错误行号
    vfprintf(stderr,s,ap);
    fprintf(stderr,"\n");
}
int main()
{
    varhead=(struct var*)malloc(sizeof(struct var));//变量符号表头指针
    vartail=varhead;//变量符号表尾指针

    funchead=(struct func*)malloc(sizeof(struct func));//函数符号表头指针
    functail=(struct func*)malloc(sizeof(struct func));//函数符号表头指针
    funchead->next=functail;//函数符号表尾指针
    functail->pnum=0;
    arrayhead=(struct array*)malloc(sizeof(struct array));//数组符号表头指针
    arraytail=arrayhead;

    struchead=(struct struc*)malloc(sizeof(struct struc));//结构体符号表头指针
    structail=struchead;//结构体符号表尾指针

    return yyparse();
}



