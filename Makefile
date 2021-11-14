CC=g++
FLEX=flex
BISON=bison
	
.PHONY: clean
.lex: src/lex.l
	$(FLEX) -o src/lex.cpp src/lex.l
.syntax: src/syntax.y
	$(BISON) -o src/syntax.cpp -t -d -v src/syntax.y
splc: .lex .syntax src/tnode.c src/main.cpp
	$(CC) src/main.cpp src/tnode.c src/splc_log.cpp  -lfl -ly -o ./bin/splc
all: splc
clean:
	@rm -f bin/*
	@rm -f src/lex.cpp src/syntax.cpp src/syntax.hpp src/syntax.output
