CC=g++
FLEX=flex
BISON=bison

.PHONY: clean
.lex: lex.l
	$(FLEX) lex.l
.syntax: syntax.y
	$(BISON) -t -d -v syntax.y
splc: .lex .syntax tnode.cpp
	$(CC) tnode.cpp main.cpp -lfl -ly -o ../bin/splc
clean:
	@rm -f bin/*
	@rm -f build/*