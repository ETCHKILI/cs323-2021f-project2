// Created by gyb on 2021/12/13.
//

#include <iostream>
#include "ast.hpp"

Ast::Ast(const std::string &type): type(type) {}

Ast::Ast(const std::string &type, const std::string &name) : type(type), name(name) {}

Ast::Ast(const std::string &type, int val) : type(type), val(val) {}

Ast::Ast(const std::string &type, const std::string &name, int val) : type(type), name(name), val(val) {}

void Ast::AddSub(int n, ...) {
    va_list list;
    va_start(list, n);
    while (n > 0) {
        this->subs.push_back(va_arg(list, Ast *));
        --n;
    }
    va_end(list);
}



IrCodeList Ast::Parse() {

    if (type == "FunDec") {
        return this->TransFunDec();
    } else if (type == "Stmt") {
        return this->TransStmt();
    } else if (type == "Exp") {
        return this->TransExp(GetTmp());
    } else if (type == "Args") {
        return this->TransArgs();
    } else if (type == "Dec") {
        return this->TransDec();
    } else {
        return this->TransSub();
    }

}

void Ast::init() {
    tmp_cnt = 0;
    lab_cnt = 0;
}

IrCodeList Ast::TransStmt() {
    IrCodeList list;

    if (name == "ExpSt" || name == "CmpSt") {
        list += this->TransSub();
    } else if (name == "ReturnSt") {
        int i = GetTmp();
        list += this->subs[0]->TransExp(i);
        list += new IrCode("RETURN t" + std::to_string(i));
    } else if (name == "IfSt") {
        int l1 = GetLab(), l2 = GetLab();
        list += this->subs[0]->TransCondExp(l1, l2);
        list += new IrCode("LABEL label" + std::to_string(l1) + " :");
        list += this->subs[1]->TransStmt();
        list += new IrCode("LABEL label" + std::to_string(l2) + " :");
    } else if (name == "IfElseSt") {
        int l1 = GetLab(), l2 = GetLab(), l3 = GetLab();
        list += this->subs[0]->TransCondExp(l1, l2);
        list += new IrCode("LABEL label" + std::to_string(l1) + " :");
        list += this->subs[1]->TransStmt();
        list += new IrCode("GOTO label" + std::to_string(l3));
        list += new IrCode("LABEL label" + std::to_string(l2) + " :");
        list += this->subs[2]->TransStmt();
        list += new IrCode("LABEL label" + std::to_string(l3) + " :");
    } else if (name == "WhileSt") {
        int l1 = GetLab(), l2 = GetLab(), l3 = GetLab();
        list += new IrCode("LABEL label" + std::to_string(l1) + " :");
        list += this->subs[0]->TransCondExp(l2, l3);
        list += new IrCode("LABEL label" + std::to_string(l2) + " :");
        list += this->subs[1]->TransStmt();
        list += new IrCode("GOTO label" + std::to_string(l1));
    }
    return list;
}

IrCodeList Ast::TransExp(int tmp) {
    IrCodeList list{};
    if (name == "+" || name == "*" || name == "/" ) {
        int i1 = GetTmp();
        list += this->subs[0]->TransExp(i1);
        int i2 = GetTmp();
        list += this->subs[1]->TransExp(i2);
        list += new IrCode("t" + std::to_string(tmp) + " := t"
                + std::to_string(i1) + " " + name + " t" + std::to_string(i2));
    } else if (name == "=") {
        int i = GetTmp();
        list += this->subs[1]->TransExp(i);
        list += new IrCode(this->subs[0]->subs[0]->name + " := t"
                + std::to_string(i) );
    } else if (name == "-") {
        if (this->subs.size() == 1) {
            int i = GetTmp();
            list += this->subs[0]->TransExp(i);
            list += new IrCode("t" + std::to_string(tmp) + " := #0"
                        + " - t" + std::to_string(i));
        } else {
            int i1 = GetTmp();
            list += this->subs[0]->TransExp(i1);
            int i2 = GetTmp();
            list += this->subs[1]->TransExp(i2);
            list += new IrCode("t" + std::to_string(tmp) + " := t"
                   + std::to_string(i1) + " " + name + " t" + std::to_string(i2));
        }
    } else if (name == "CALL") {
        if (this->subs[0]->name == "read") {
            list += new IrCode("READ t" + std::to_string(tmp));
        } else if (this->subs[0]->name == "write") {
            int i = GetTmp();
            list += this->subs[1]->subs[0]->TransExp(i);
            list += new IrCode("WRITE t" + std::to_string(i));
        } else {
            if (this->subs.size() > 1) {
                list += this->subs[1]->TransArgs();
            }
            list += new IrCode("t" + std::to_string(tmp) + " := CALL " + this->subs[0]->name);
        }
    } else if (name == "INT") {
        list += new IrCode("t" + std::to_string(tmp) + " := #" + std::to_string(this->val));
    } else if (name == "ID") {
        list += new IrCode("t" + std::to_string(tmp) + " := " + this->subs[0]->name);
    }
    return list;
}

IrCodeList Ast::TransFunDec() {
    auto t1 = new IrCode("FUNCTION " + this->name + " :");
    IrCodeList list(t1);
    if (!this->subs.empty()) {
        for (auto &item : this->subs[0]->subs) {
            list += new IrCode("PARAM " + item->name);
        }
    }

    return list;
}

IrCodeList Ast::TransSub() {
    IrCodeList list;
    for (auto &item : this->subs) {
        list += item->Parse();
    }
    return list;
}

IrCodeList Ast::TransCondExp(int l1, int l2) {
    IrCodeList list;

    if (name == "<" || name == "<=" || name == ">" || name == ">=" || name == "==" || name == "!=") {
        int i = GetTmp();
        list += this->subs[0]->TransExp(i);
        list += this->subs[1]->TransExp(i + 1);
        list += new IrCode("IF t" + std::to_string(i) + " " + name + " t" +
                std::to_string(i + 1) + " GOTO label" + std::to_string(l1));
        list += new IrCode("GOTO label" + std::to_string(l2));


//        list += new IrCode("LABEL label" + std::to_string(l1));
//
//        list += new IrCode()
//
//        list += new IrCode("LABEL label" + std::to_string(l2));
    } else if (name == "||") {
        int i = GetLab();
        list += this->subs[0]->TransCondExp(l1, i);
        list += new IrCode("LABEL label" + std::to_string(i) + " :");
        list += this->subs[1]->TransCondExp(l1, l2);
    } else if (name == "&&") {
        int i = GetLab();
        list += this->subs[0]->TransCondExp(i, l2);
        list += new IrCode("LABEL label" + std::to_string(i) + " :");
        list += this->subs[1]->TransCondExp(l1, l2);
    } else if (name == "!") {
        list += this->subs[0]->TransCondExp(l2, l1);
    }

    return list;
}

int Ast::GetTmp() {
    return tmp_cnt++;
}

int Ast::GetLab() {
    return lab_cnt++;
}

IrCodeList Ast::TransArgs() {
    IrCodeList list{};
    int i;
    for (auto &item: this->subs) {
        i = GetTmp();
        list += item->TransExp(i);
        list += new IrCode("ARG t" + std::to_string(i));
    }
    return list;
}

IrCodeList Ast::TransDec() {
    IrCodeList list;
    if (this->subs.size() == 2) {
        int i = GetTmp();
        list += this->subs[1]->TransExp(i);
        list += new IrCode(this->subs[0]->name + " := t" + std::to_string(i));
    }
    return list;
}

void Ast::AddSubFront(Ast *sub) {
    this->subs.insert(this->subs.cbegin(), sub);
}





