%{
    #include "lex.cpp"
    void yyerror(const char *s);
    #include "stdio.h"
    #include "stdlib.h"
    #include "string.h"
    #include <unordered_map>
    #include <memory>
    #include "symbol_node.hpp"

    extern Scope global_scope;
    extern Scope *current_scope;
    extern Scope *last_scope;
    Type *tmp_type;
    
    struct tnode *head;
%}

%union 
{
    struct {
        struct tnode *nd;
        union {
            SymbolNode *snd;
            Type *tp;
            Array *arr;
            Field *fld;
        };
        bool lv;
    } agg; 
    // aggregate
}

%nonassoc <nd> ILLEGAL_TOKEN
%nonassoc <nd> LOWER_ELSE
%nonassoc <nd> ELSE
%token <nd> TYPE STRUCT
%token <nd> IF WHILE RETURN
%token <nd> INT
%token <nd> FLOAT
%token <nd> CHAR
%token <nd> ID
%right <nd> ASSIGN
%left <nd> OR
%left <nd> AND
%left <nd> LT LE GT GE NE EQ

%left <nd> PLUS MINUS
%left <nd> MUL DIV
%right <nd> NOT
%left <nd> LP RP LB RB DOT
%token <nd> SEMI COMMA
%token <nd> LC RC

%type <nd> Program ExtDefList
%type <nd> ExtDef ExtDecList Specifier StructSpecifier VarDec
%type <nd> FunDec VarList ParamDec CompSt StmtList Stmt DefList
%type <nd> Def DecList Dec Args Exp

%%
/* high-level definition */
Program:
    ExtDefList {
        head=new_tnode("Program",1,$<agg.nd>1);  
        $<agg.nd>$=head;  
    }
    ;

ExtDefList:
    {$<agg.nd>$=new_tnode("ExtDef",0,-1);}
    | ExtDef ExtDefList {
        $<agg.nd>$=new_tnode("ExtDefList",2,$<agg.nd>1,$<agg.nd>2);
    } 
    ;

ExtDef:
    Specifier ExtDecList SEMI {
        $<agg.nd>$=new_tnode("ExtDef",3,$<agg.nd>1,$<agg.nd>2,$<agg.nd>3);
    }
    | Specifier SEMI {$<agg.nd>$=new_tnode("ExtDef",2,$<agg.nd>1,$<agg.nd>2);}
    | Specifier FunDec CompSt {
        $<agg.nd>$=new_tnode("ExtDef",3,$<agg.nd>1,$<agg.nd>2,$<agg.nd>3);

        if (SymbolConflict($<agg.nd->str_val>1)) {
            LogSemanticErrorTL(3, @$.first_line, "Function redefined");
        }
        SymbolNode *tmp_snd = new SymbolNode(@$.first_line, $<agg.nd->str_val>2, $<agg.tp>1); 
        global_scope.map[tmp_snd->id] = tmp_snd;
        $<agg.snd>$ = tmp_snd;
        
    }
    | Specifier ExtDecList error { LogLSErrorTL(1, yylineno, "Missing Semi"); YYABORT; }
    | Specifier error { LogLSErrorTL(1, yylineno, "Missing Semi"); YYABORT; }
    ;

ExtDecList:
    VarDec {
        $<agg.nd>$ = new_tnode("ExtDecList",1,$<agg.nd>1);
        if (SymbolConflict($<agg.nd->str_val>1)) {
            LogSemanticErrorTL(3, @$.first_line, "Variable redefined");
        }
        SymbolNode *tmp_snd = new SymbolNode(@$.first_line, $<agg.nd->str_val>1, $<agg.tp>1); 
        global_scope.map[tmp_snd->id] = tmp_snd;
        $<agg.snd>$ = tmp_snd;  
    }
    | VarDec COMMA ExtDecList {
        $<agg.nd>$=new_tnode("ExtDecList",3,$<agg.nd>1,$<agg.nd>2,$<agg.nd>3);
        if (SymbolConflict($<agg.nd->str_val>1)) {
            LogSemanticErrorTL(3, @$.first_line, "Variable redefined");
        }
        SymbolNode *tmp_snd = new SymbolNode(@$.first_line, $<agg.nd->str_val>1, $<agg.tp>1); 
        global_scope.map[tmp_snd->id] = tmp_snd;
        $<agg.snd>$ = tmp_snd;
    }
    | VarDec ExtDecList error { LogLSErrorTL(1, yylineno, "Missing Comma"); YYABORT;}
    ;


/* specifier */
Specifier: 
    TYPE {
        $<agg.nd>$ = new_tnode("Specifier",1,$<agg.nd>1); 
        $<agg.tp>$ = getPrimitiveType($<agg.nd->str_val>1);
        tmp_type = $<agg.tp>$;
    }
    | StructSpecifier {
        $<agg.nd>$ = new_tnode("Specifier",1,$<agg.nd>1); 
        $<agg.tp>$ = $<agg.tp>1;
        tmp_type = $<agg.tp>$;
    }
    ;
StructSpecifier: 
    STRUCT ID LC DefList RC {
        $<agg.nd>$ = new_tnode("StructSpecifier",5,$<agg.nd>1,$<agg.nd>2,$<agg.nd>3,$<agg.nd>4,$<agg.nd>5);
        auto f = getFieldFromScope(last_scope); 
        $<agg.tp>$ = getStructType($<agg.nd->str_val>2, f);
        tmp_type = $<agg.tp>$;
    }
    | STRUCT ID {
        $<agg.nd>$=new_tnode("StructSpecifier",2,$<agg.nd>1,$<agg.nd>2);
        $<agg.tp>$ = getStructType($<agg.nd->str_val>2);
        tmp_type = $<agg.tp>$;
    }
    | STRUCT ID LC DefList error { LogLSErrorTL(1, yylineno, "Missing RC"); YYABORT;}
    ;

/* declarator */
VarDec: 
    ID { 
        $<agg.nd>$=new_tnode("VarDec",1,$<agg.nd>1); 
        $<agg.nd->str_val>$ = $<agg.nd->str_val>1;
        $<agg.tp>$ = tmp_type;
    }
    | VarDec LB INT RB {
        $<agg.nd>$=new_tnode("VarDec",4,$<agg.nd>1,$<agg.nd>2,$<agg.nd>3,$<agg.nd>4);
        $<agg.nd->str_val>$ = $<agg.nd->str_val>1;
        
        if ($<agg.tp->category>1 != Category::ARRAY) {
            $<agg.tp>$ = getArrayType(new Array(tmp_type, $<agg.nd->int_val>3));
        } else {
            Array *sub_arr = new Array(tmp_type, $<agg.nd->int_val>3);
            (findLastArr($<agg.tp>1))->base = getArrayType(sub_arr);
        }
    }
    | VarDec LB INT error %prec LOWER_ELSE { 
        LogLSErrorTL(1, yylineno, "Missing RB"); 
        YYABORT;
    }
    ;
FunDec: 
    ID LP VarList RP {
        $<agg.nd>$=new_tnode("FunDec",4,$<agg.nd>1,$<agg.nd>2,$<agg.nd>3,$<agg.nd>4);
        $<agg.nd->str_val>$ = $<agg.nd->str_val>1;
        
        auto func_type = makeFuncType(tmp_type, $<agg.fld>3);
        $<agg.tp>$ = func_type;
    }
    | ID LP RP {
        $<agg.nd>$=new_tnode("FunDec",3,$<agg.nd>1,$<agg.nd>2,$<agg.nd>3);
        $<agg.nd->str_val>$ = $<agg.nd->str_val>1;
        
        auto func_type = makeFuncType(tmp_type, nullptr);
        $<agg.tp>$ = func_type;
    }
    | ID LP VarList error { LogLSErrorTL(1, yylineno, "Missing RP"); YYABORT;}
    | ID LP error { LogLSErrorTL(1, yylineno, "Missing RP"); YYABORT;}
    ;
VarList: 
    ParamDec COMMA VarList {
        $<agg.nd>$=new_tnode("VarList",3,$<agg.nd>1,$<agg.nd>2,$<agg.nd>3);
        $<agg.fld>$ = PushBackField($<agg.fld>1, $<agg.fld>2);
    }
    | ParamDec VarList error { LogLSErrorTL(1, yylineno, "Missing Comma"); YYABORT;}
    | ParamDec {
        $<agg.nd>$=new_tnode("VarList",1,$<agg.nd>1);
        $<agg.fld>$ = $<agg.fld>1;
    }
    ;
ParamDec: 
    Specifier VarDec {
        $<agg.nd>$=new_tnode("ParamDec",2,$<agg.nd>1,$<agg.nd>2);
        $<agg.fld>$ = new Field($<agg.nd->str_val>2, $<agg.tp>2);
    }
    ;  

/* statement */
CompSt: 
    LC DefList StmtList RC {
        $<agg.nd>$=new_tnode("CompSt",4,$<agg.nd>1,$<agg.nd>2,$<agg.nd>3,$<agg.nd>4);
    }
    ;
StmtList: 
    {$<agg.nd>$=new_tnode("StmtList",0,-1);}
    | Stmt StmtList {$<agg.nd>$=new_tnode("StmtList",2,$<agg.nd>1,$<agg.nd>2);}
    ;
Stmt: 
    Exp SEMI {$<agg.nd>$=new_tnode("Stmt",2,$<agg.nd>1,$<agg.nd>2);}
    | CompSt {$<agg.nd>$=new_tnode("Stmt",1,$<agg.nd>1);}
    | RETURN Exp SEMI {$<agg.nd>$=new_tnode("Stmt",3,$<agg.nd>1,$<agg.nd>2,$<agg.nd>3);}
    | IF LP Exp RP Stmt %prec LOWER_ELSE {$<agg.nd>$=new_tnode("Stmt",5,$<agg.nd>1,$<agg.nd>2,$<agg.nd>3,$<agg.nd>4,$<agg.nd>5);}
    | IF LP Exp RP Stmt ELSE Stmt {$<agg.nd>$=new_tnode("Stmt",7,$<agg.nd>1,$<agg.nd>2,$<agg.nd>3,$<agg.nd>4,$<agg.nd>5,$<agg.nd>6,$<agg.nd>7);}
    | WHILE LP Exp RP Stmt {$<agg.nd>$=new_tnode("Stmt",5,$<agg.nd>1,$<agg.nd>2,$<agg.nd>3,$<agg.nd>4,$<agg.nd>5);}
    | WHILE LP Exp error Stmt {LogLSErrorTL(1,yylineno,"Missing RP"); YYABORT;}
    | RETURN Exp error {LogLSErrorTL(1,yylineno,"Missing SEMI"); YYABORT;}
    | IF LP Exp error Stmt {LogLSErrorTL(1,yylineno,"Missing RP"); YYABORT;}
    | IF error Exp RP Stmt {LogLSErrorTL(1,yylineno,"Missing LP"); YYABORT;}
    ;

/* local definition */
DefList: 
    {$<agg.nd>$=new_tnode("DefList",0,-1);}
    | Def DefList {$<agg.nd>$=new_tnode("DefList",2,$<agg.nd>1,$<agg.nd>2);}
    ;
Def: 
    Specifier DecList SEMI {
        $<agg.nd>$=new_tnode("Def",3,$<agg.nd>1,$<agg.nd>2,$<agg.nd>3);
    }
    | Specifier DecList error {LogLSErrorTL(1,yylineno,"Missing SEMI"); YYABORT;}
    | error DecList SEMI {LogLSErrorTL(1,yylineno,"Missing Specifier"); YYABORT;}
    ;
DecList: 
    Dec {
        $<agg.nd>$=new_tnode("DecList",1,$<agg.nd>1);
        
        auto s = new SymbolNode(@$.first_line, $<agg.nd->str_val>1, $<agg.tp>1);
        current_scope->map[s->id] = s;
    }
    | Dec COMMA DecList {
        $<agg.nd>$=new_tnode("DecList",3,$<agg.nd>1,$<agg.nd>2,$<agg.nd>3);
        
        auto s = new SymbolNode(@$.first_line, $<agg.nd->str_val>1, $<agg.tp>1);
        current_scope->map[s->id] = s;
    }
    | Dec DecList error {LogLSErrorTL(1,yylineno,"Missing Comma"); YYABORT;}
    ;
Dec: 
    VarDec {
        $<agg.nd>$=new_tnode("Dec",1,$<agg.nd>1);
        $<agg.nd->str_val>$ = $<agg.nd->str_val>1;
        $<agg.tp>$ = $<agg.tp>1;
    }
    | VarDec ASSIGN Exp {
        $<agg.nd>$=new_tnode("Dec",3,$<agg.nd>1,$<agg.nd>2,$<agg.nd>3);
        $<agg.nd->str_val>$ = $<agg.nd->str_val>1;
        $<agg.tp>$ = $<agg.tp>1;

        if (!CheckType($<agg.tp>1, $<agg.tp>3)) {
            LogSemanticErrorTL(5, @1.first_line, "unmatched type");
        }
        if ($<agg.lv>1 == false) {
            LogSemanticErrorTL(6, @1.first_line, "Rvalue on the left side of ASSIGN");
        }
    }
    ;


/* Expression */
Exp: 
    Exp ASSIGN Exp {
        $<agg.nd>$=new_tnode("Exp",3,$<agg.nd>1,$<agg.nd>2,$<agg.nd>3);
        if (!CheckType($<agg.tp>1, $<agg.tp>3)) {
            LogSemanticErrorTL(5, @2.first_line, "unmatched type");
        }
        if ($<agg.lv>1 == false) {
            LogSemanticErrorTL(6, @1.first_line, "Rvalue on the left side of ASSIGN");
        }
    }
    | Exp AND Exp {
        $<agg.nd>$=new_tnode("Exp",3,$<agg.nd>1,$<agg.nd>2,$<agg.nd>3);
        $<agg.tp>$ = $<agg.tp>1;
        if (!CheckInt($<agg.tp>1, $<agg.tp>3)) {
            LogSemanticErrorTL(7, @2.first_line, "unmatched operand");
        }
    }
    | Exp OR Exp {
        $<agg.nd>$=new_tnode("Exp",3,$<agg.nd>1,$<agg.nd>2,$<agg.nd>3);
        $<agg.tp>$ = $<agg.tp>1;
        if (!CheckInt($<agg.tp>1, $<agg.tp>3)) {
            LogSemanticErrorTL(7, @2.first_line, "unmatched operand");
        }
    }
    | Exp LT Exp {
        $<agg.nd>$=new_tnode("Exp",3,$<agg.nd>1,$<agg.nd>2,$<agg.nd>3);
        $<agg.tp>$ = $<agg.tp>1;
        if (!CheckIF($<agg.tp>1, $<agg.tp>3)) {
            LogSemanticErrorTL(7, @2.first_line, "unmatched operand");
        }
    }
    | Exp LE Exp {
        $<agg.nd>$=new_tnode("Exp",3,$<agg.nd>1,$<agg.nd>2,$<agg.nd>3);
        $<agg.tp>$ = $<agg.tp>1;
        if (!CheckIF($<agg.tp>1, $<agg.tp>3)) {
            LogSemanticErrorTL(7, @2.first_line, "unmatched operand");
        }
    }
    | Exp GT Exp {
        $<agg.nd>$=new_tnode("Exp",3,$<agg.nd>1,$<agg.nd>2,$<agg.nd>3);
        $<agg.tp>$ = $<agg.tp>1;
        if (!CheckIF($<agg.tp>1, $<agg.tp>3)) {
            LogSemanticErrorTL(7, @2.first_line, "unmatched operand");
        }      
    }
    | Exp GE Exp {
        $<agg.nd>$=new_tnode("Exp",3,$<agg.nd>1,$<agg.nd>2,$<agg.nd>3);
        $<agg.tp>$ = $<agg.tp>1;
        if (!CheckIF($<agg.tp>1, $<agg.tp>3)) {
            LogSemanticErrorTL(7, @2.first_line, "unmatched operand");
        }
    }
    | Exp NE Exp {
        $<agg.nd>$=new_tnode("Exp",3,$<agg.nd>1,$<agg.nd>2,$<agg.nd>3);
        $<agg.tp>$ = $<agg.tp>1;
        if (!CheckIF($<agg.tp>1, $<agg.tp>3)) {
            LogSemanticErrorTL(7, @2.first_line, "unmatched operand");
        }
    }
    | Exp EQ Exp {
        $<agg.nd>$=new_tnode("Exp",3,$<agg.nd>1,$<agg.nd>2,$<agg.nd>3);
        $<agg.tp>$ = $<agg.tp>1;
        if (!CheckIF($<agg.tp>1, $<agg.tp>3)) {
            LogSemanticErrorTL(7, @2.first_line, "unmatched operand");
        }
    }
    | Exp PLUS Exp {
        $<agg.nd>$=new_tnode("Exp",3,$<agg.nd>1,$<agg.nd>2,$<agg.nd>3);
        $<agg.tp>$ = $<agg.tp>1;
        if (!CheckIF($<agg.tp>1, $<agg.tp>3)) {
            LogSemanticErrorTL(7, @2.first_line, "unmatched operand");
        }
    }
    | Exp MINUS Exp {
        $<agg.nd>$=new_tnode("Exp",3,$<agg.nd>1,$<agg.nd>2,$<agg.nd>3);
        $<agg.tp>$ = $<agg.tp>1;
        if (!CheckIF($<agg.tp>1, $<agg.tp>3)) {
            LogSemanticErrorTL(7, @2.first_line, "unmatched operand");
        }
    }
    | Exp MUL Exp {
        $<agg.nd>$=new_tnode("Exp",3,$<agg.nd>1,$<agg.nd>2,$<agg.nd>3);
        $<agg.tp>$ = $<agg.tp>1;
        if (!CheckIF($<agg.tp>1, $<agg.tp>3)) {
            LogSemanticErrorTL(7, @2.first_line, "unmatched operand");
        }
    }
    | Exp DIV Exp {
        $<agg.nd>$=new_tnode("Exp",3,$<agg.nd>1,$<agg.nd>2,$<agg.nd>3);
        $<agg.tp>$ = $<agg.tp>1;
        if (!CheckIF($<agg.tp>1, $<agg.tp>3)) {
            LogSemanticErrorTL(7, @2.first_line, "unmatched operand");
        } 
    }
    | LP Exp RP {
        $<agg.nd>$=new_tnode("Exp",3,$<agg.nd>1,$<agg.nd>2,$<agg.nd>3);
        $<agg.tp>$ = $<agg.tp>2;
    }
    | LP Exp error {LogLSErrorTL(1,yylineno,"Missing RP"); YYABORT;}
    | MINUS Exp {
        $<agg.nd>$=new_tnode("Exp",2,$<agg.nd>1,$<agg.nd>2);
        $<agg.tp>$ = $<agg.tp>2;
        if (!CheckIF($<agg.tp>2, $<agg.tp>2)) {
            LogSemanticErrorTL(7, @1.first_line, "unmatched operand");
        } 
    }
    | NOT Exp {
        $<agg.nd>$=new_tnode("Exp",2,$<agg.nd>1,$<agg.nd>2);
        $<agg.tp>$ = $<agg.tp>2;
        if (!CheckInt($<agg.tp>2, $<agg.tp>2)) {
            LogSemanticErrorTL(7, @1.first_line, "unmatched operand");
        } 
    }
    | ID LP Args RP {
        $<agg.nd>$=new_tnode("Exp",4,$<agg.nd>1,$<agg.nd>2,$<agg.nd>3,$<agg.nd>4);
        $<agg.nd->str_val>$ = $<agg.nd->str_val>1;
        auto p_type = LookUpSymbolType($<agg.nd->str_val>1);
        if (p_type == nullptr) {
            LogSemanticErrorTL(2, @$.first_line, "Function used without define");
        }
        $<agg.tp>$ = p_type;
        $<agg.lv>$ = false;
    }
    | ID LP Args error {LogLSErrorTL(1,yylineno,"Missing RP"); YYABORT;}
    | ID LP RP {
        $<agg.nd>$=new_tnode("Exp",3,$<agg.nd>1,$<agg.nd>2,$<agg.nd>3);
        $<agg.nd->str_val>$ = $<agg.nd->str_val>1;
        auto p_type = LookUpSymbolType($<agg.nd->str_val>1);
        if (p_type == nullptr) {
            LogSemanticErrorTL(2, @$.first_line, "Function used without define");
        }
        $<agg.tp>$ = p_type;
        $<agg.lv>$ = false;
    }
    | ID LP error   {LogLSErrorTL(1,yylineno,"Missing RP"); YYABORT;}
    | Exp LB Exp RB {
        $<agg.nd>$=new_tnode("Exp",4,$<agg.nd>1,$<agg.nd>2,$<agg.nd>3,$<agg.nd>4);
    }
    | Exp LB Exp error  {LogLSErrorTL(1,yylineno,"Missing RB"); YYABORT;}
    | Exp DOT ID {
        $<agg.nd>$=new_tnode("Exp",3,$<agg.nd>1,$<agg.nd>2,$<agg.nd>3);
        $<agg.nd->str_val>$ = $<agg.nd->str_val>1;
        $<agg.nd->str_val>$ = $<agg.nd->str_val>3;
        $<agg.lv>$ = true;
    }
    | ID {
        $<agg.nd>$=new_tnode("Exp",1,$<agg.nd>1);
        $<agg.nd->str_val>$ = $<agg.nd->str_val>1;
        auto p_type = LookUpSymbolType($<agg.nd->str_val>1);
        if (p_type == nullptr) {
            LogSemanticErrorTL(1, @$.first_line, "variable used without define");
        }
        $<agg.tp>$ = p_type;
        $<agg.lv>$ = true;
    }
    | INT {$<agg.nd>$=new_tnode("Exp",1,$<agg.nd>1); }
    | FLOAT {$<agg.nd>$=new_tnode("Exp",1,$<agg.nd>1);}
    | CHAR {$<agg.nd>$=new_tnode("Exp",1,$<agg.nd>1);}
    | ILLEGAL_TOKEN Exp {$<agg.nd>$=new_tnode("Exp",2,$<agg.nd>1,$<agg.nd>2); YYABORT; }
    | ILLEGAL_TOKEN {$<agg.nd>$=new_tnode("Exp",1,$<agg.nd>1); YYABORT; }
    ;
Args: 
    Exp COMMA Args {$<agg.nd>$=new_tnode("Args",3,$<agg.nd>1,$<agg.nd>2,$<agg.nd>3);}
    | Exp {$<agg.nd>$=new_tnode("Args",1,$<agg.nd>1);}
    | Exp Args error {LogLSErrorTL(1,yylineno,"Missing Comma"); YYABORT;}
    

%%

void yyerror(const char *s){
}
