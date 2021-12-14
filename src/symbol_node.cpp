//
// Created by gyb on 2021/11/15.
//

#include "symbol_node.hpp"

//SymbolNode::SymbolNode(int line, const char *id, Type *type) : line(line), id(id), type(type) {
//
//}

SymbolNode::SymbolNode(int line, const std::string &id, Type *type) : line(line), id(id), type(type) {}

Scope *StartScope() {
    scope_open++;
    auto tmp = new Scope();
    current_scope->subscopes.push_back(tmp);
    tmp->fa = current_scope;
    current_scope = tmp;
    return tmp;
}

Scope *EndScope() {
    scope_open--;
    last_scope = current_scope;
    current_scope = current_scope->fa;
    return current_scope;
}

bool SymbolConflict(const std::string& id) {
    if (current_scope->map.count(id)) {
        return true;
    }
    return false;
}

bool SymbolDefined(const std::string& id) {
    auto tmp = current_scope;
    do {
        if (tmp->map.count(id)) {
            return true;
        }
    } while ((tmp=tmp->fa) != nullptr);
    return false;
}

Type *LookUpSymbolType(const std::string& id) {
    auto tmp = current_scope;
    do {
        if (tmp->map.count(id)) {
            break;
        }
    } while ((tmp=tmp->fa) != nullptr);
    return tmp->map[id]->type;
}

Field *getFieldFromScope(Scope *sc) {
    auto m = sc->map;
    Field *tmp = nullptr;
    Field *head = nullptr;
    for (const auto& i: m) {
        tmp = new Field(i.first, i.second->type);
        if (head == nullptr) {
            head = tmp;
        } else {
            PushBackField(head, tmp);
        }
    }
    return head;
}