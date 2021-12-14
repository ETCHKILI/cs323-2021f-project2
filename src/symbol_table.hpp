//
// Created by gyb on 2021/11/14.
//
#ifndef CS323_2021F_PROJECT2_SYMBOL_TABLE_HPP
#define CS323_2021F_PROJECT2_SYMBOL_TABLE_HPP


#include <unordered_map>
#include <vector>
#include <string>
#include <variant>
#include <memory>
#include "splc_log.hpp"
#include "tnode.hpp"

enum Category { PRIMITIVE=0, ARRAY=1, STRUCTURE=2 };
enum Primitive { PR_INT=0, PR_FLOAT=1, PR_CHAR=2 };

class Type;

class Array {
public:
    Type *base;
    int size;

    Array()=default;
    Array(Type *base, int size);
    
};

class Field {
public:
    std::string name;
    Type *type;
    Field *next;

    Field(const std::string &name, Type *type);
};

//class Func {
//public:
//    Field *params;
//    Type *return_type;
//
//    Func(Field *params, Type *returnType);
//};

class Type {
public:
    std::string name;
    Category category=Category::PRIMITIVE;
    union {
        Primitive primitive=Primitive::PR_INT;
        Array *array;
        Field *field_list;
    };
    Field *params = nullptr;
    bool is_func = false;

    Type()=default;
    Type(const Type &o);

    Type &operator=(const Type& o);

    bool operator==(const Type &rhs) const;

    bool operator!=(const Type &rhs) const;
};

// static std::vector<std::unordered_map<std::string, Type>> scope_stack;
// static std::unordered_map<std::string, Type>
// static int scope_id;

Type *getPrimitiveType(std::string s);
Type *getStructType(const std::string& id, Field *field_list);
Type *getStructType(const std::string& id);
Type *getArrayType(Array *array);

Type *makeFuncType(Type *tp, Field *field);

Type *findLastType(Type *tp);

Array *findLastArr(Type *arr);

Field *PushBackField(Field *head, Field *src);

bool CheckType(Type *a, Type *b);
bool CheckArray(Array *a, Array *b);
bool CheckInt(Type *a, Type *b);
bool CheckIF(Type *a, Type *b);




#endif //CS323_2021F_PROJECT2_SYMBOL_TABLE_HPP
