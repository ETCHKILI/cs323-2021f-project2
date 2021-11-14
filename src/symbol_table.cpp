//
// Created by gyb on 2021/11/15.
//

#include "symbol_table.hpp"

void InitScope() {
    scope_stack.emplace_back();
}

void NewScope() {
    scope_stack.emplace_back();
}

void EndScope() {
    scope_stack.pop_back();
}

void InsertSymbol(std::string name) {
    auto tmp = scope_stack.back();
    if (tmp.count(name)) {

    }
}



