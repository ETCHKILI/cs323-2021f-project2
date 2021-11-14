//
// Created by gyb on 2021/11/14.
//

#include <unordered_map>
#include <vector>
#include <string>

class Type;
class Array;
class FieldList;

class Type {
public:
    std::string name;
    enum { PRIMITIVE, ARRAY, STRUCTURE } category;
    union {
        enum { INT, FLOAT, CHAR } primitive;
        Array *array;
        std::vector<FieldList>
    };
};

class Array {
public:
    Type *base;
    int size;
};

class FieldList {
    std::string name;
    Type *type;
};

static std::vector<std::unordered_map<std::string, Type>> scope_stack;
