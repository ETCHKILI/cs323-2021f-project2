//
// Created by gyb on 2021/11/14.
//
#ifndef CS323_2021F_PROJECT2_SYMBOL_TABLE_HPP
#define CS323_2021F_PROJECT2_SYMBOL_TABLE_HPP


#include <unordered_map>
#include <vector>
#include <string>

enum Category { PRIMITIVE=0, ARRAY=1, STRUCTURE=2 };
enum Primitive { PR_INT, PR_FLOAT, PR_CHAR };

typedef struct Array {
    struct Type *base;
    int size;
} Array;

typedef struct Field {
    std::string name;
    struct Type *type;
} Field;

typedef struct Type {
    std::string name;
    Category category;
    union {
        Primitive primitive;
        struct Array *array;
        struct Field *field_list;
    };
} Type;

static std::vector<std::unordered_map<std::string, Type>> scope_stack;
static int scope_id;


#endif //CS323_2021F_PROJECT2_SYMBOL_TABLE_HPP
