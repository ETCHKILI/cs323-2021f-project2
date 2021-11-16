#ifndef CS323_2021F_PROJECT2_TNODE_HPP
#define CS323_2021F_PROJECT2_TNODE_HPP

extern int yylineno;
extern char* yytext;

struct tnode
{
    int line; 
    char* name;
    struct tnode *left;
    struct tnode *right;
    union
    {
        char* str_val;
        int int_val;
        float flt_val;
    };
};


struct tnode *new_tnode(const char *name,int num,...);

int check_terminate(const char* name);

void print_parsetree(struct tnode*,int level);

#endif //CS323_2021F_PROJECT2_TNODE_HPP