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
    params = o.params;
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
    }
    return (*this);
}



bool Type::operator==(const Type &rhs) const {
    return false;
}

bool Type::operator!=(const Type &rhs) const {
    return !(rhs == *this);
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

Type *makeFuncType(Type *tp, Field *field) {
    tp->params = field;
    tp->is_func = true;
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


Field::Field(const std::string &name, Type *type) : name(name), type(type) {}

bool CheckType(Type *a, Type *b) {
    if (!a || !b) {
        return false;
    }
    if (a->category ==Category::PRIMITIVE && b->category == Category::PRIMITIVE) {
        return a->primitive == b->primitive;
    }
    if (a->category == Category::STRUCTURE && b->category == Category::STRUCTURE) {
        return a->name == b->name;
    }
    if (a->category == Category::ARRAY && b->category == Category::ARRAY ) {
        return CheckArray(a->array, b->array);
    }
    return false;
}

bool CheckArray(Array *a, Array *b) {
    if (!a || !b) {
        return false;
    }
    if (a->size != b->size) {
        return false;
    } else if (!CheckType(a->base, b->base)) {
        return false;
    }
    return true;
}

bool CheckInt(Type *a, Type *b) {
    if (!a || !b) {
        return false;
    }

    return a->category == Category::PRIMITIVE
        && b->category == Category::PRIMITIVE
        && a->primitive == Primitive::PR_INT
        && b->primitive == Primitive::PR_INT;
}   


bool CheckIF(Type *a, Type *b) {
    if (!a || !b) {
        return false;
    }

    return a->category == Category::PRIMITIVE
        && b->category == Category::PRIMITIVE
        && (
            (a->primitive == Primitive::PR_INT && b->primitive == Primitive::PR_INT) || 
            (a->primitive == Primitive::PR_FLOAT && b->primitive == Primitive::PR_FLOAT)
        );
        
        
        
}
