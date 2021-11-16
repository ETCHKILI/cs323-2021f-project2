//
// Created by gyb on 2021/11/15.
//

#ifndef CS323_2021F_PROJECT2_SYMBOL_NODE_HPP
#define CS323_2021F_PROJECT2_SYMBOL_NODE_HPP

#include <memory>
#include <vector>
#include <string>
#include <unordered_map>
#include "symbol_table.hpp"

static int scope_open = 0;

class SymbolNode {
public:
    int line;
    std::string id;
    Type *type;

    SymbolNode()=default;

    SymbolNode(int line, const std::string &id, Type *type);
};

class Scope {
public:
    std::unordered_map<std::string, SymbolNode*> map;
    std::vector<Scope*> subscopes;
    Scope *fa;
};

static Scope global_scope;
static Scope *current_scope = &global_scope;
static Scope *last_scope = nullptr;


Scope *StartScope();

Scope *EndScope();

bool SymbolConflict(std::string id);

bool LookUpSymbol(std::string id);

Field *getFieldFromScope(Scope *sc);


#endif //CS323_2021F_PROJECT2_SYMBOL_NODE_HPP
