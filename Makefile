CC=g++
FLEX=flex
BISON=bison

.PHONY: clean
.lex: src/lex.l
	$(FLEX) -o src/lex.yy.c src/lex.l
.syntax: src/syntax.y
	$(BISON) -o src/syntax.tab.c -t -d -v src/syntax.y
splc: .lex .syntax src/tnode.cpp src/main.cpp
	$(CC) src/tnode.cpp src/main.cpp -lfl -ly -o bin/splc
clean:
	@rm -f bin/*
	@rm -f build/*
	@rm -f src/lex.yy.c src/syntax.tab.c src/syntax.tab.h src/syntax.output