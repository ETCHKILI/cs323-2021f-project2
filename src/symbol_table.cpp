//
// Created by gyb on 2021/11/15.
//

#include <iostream>
#include "symbol_table.hpp"

Array::Array(Type *base, int size): base(base), size(size){}


Type::Type(const Type &o) {
    *this = o;
}

Type &Type::operator=(const Type &o) {
    name = o.name;
    category = o.category;
    switch (o.category) {
        case Category::PRIMITIVE:
            primitive = o.primitive;
            break;
        case Category::ARRAY:
            array = o.array;
            break;
        case Category::STRUCTURE:
            field_list = o.field_list;
            break;
        case Category::FUNCTION:
            func = o.func;
            break;
    }
    return (*this);
}



Type *getPrimitiveType(std::string s) {
    Type *res = new Type();
    res->category = Category::PRIMITIVE;
    if (s == "int") {
        res->primitive = Primitive::PR_INT;
    } else if (s == "float") {
        res->primitive = Primitive::PR_FLOAT;
    } else {
        res->primitive = Primitive::PR_CHAR;
    }
    return res;
}

Type *getStructType(const std::string& id, Field *field_list) {
    Type *res = new Type();
    res->category = Category::STRUCTURE;
    res->field_list = field_list;
    res->name = id;
    return res;
}

Type *getStructType(const std::string& id) {
    Type *res = new Type();
    res->category = Category::STRUCTURE;
    res->name = id;
    return res;
}

Type *getArrayType(Array *array) {
    Type *res = new Type();
    res->category = Category::ARRAY;
    res->array = array;
    return res;
}

Type *getFuncType(Func *func) {
    Type *res = new Type();
    res->category = Category::FUNCTION;
    res->func = func;
    return res;
}

Type *findLastType(Type *tp) {
    auto tmp = tp;
    if (tmp == nullptr) {
        std::cout << "findLastArr error!";
    } 
    while (tmp->category == Category::ARRAY) {
        tmp = tmp->array->base;
    }
    return tmp;
}

Array *findLastArr(Type *arr) {
    auto tmp = arr->array;
    if (tmp == nullptr) {
        std::cout << "findLastArr error!";
    } 
    while (tmp->base->category == Category::ARRAY) {
        tmp = tmp->base->array;
    } 
    return tmp;
}

Field *PushBackField(Field *head, Field *src) {
    auto tmp = head;
    while (tmp->next != nullptr)
    {
        tmp = tmp->next;
    }
    tmp->next = src;
    return tmp;
}


Func::Func(Field *params, Type *returnType) : params(params), return_type(returnType) {}

Field::Field(const std::string &name, Type *type) : name(name), type(type) {}
