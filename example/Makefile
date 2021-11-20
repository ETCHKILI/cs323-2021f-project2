CC=gcc
FLEX=flex
BISON=bison
	
.PHONY: clean
.lex: gramtree.l
	$(FLEX) -o lex.yy.c gramtree.l
.syntax: gramtree_v1.y
	$(BISON) -o syntax.tab.c -t -d -v gramtree_v1.y
splc: .lex .syntax gramtree_v1.c
	$(CC) gramtree_v1.c -lfl -o a.out
clean:
	@rm -f bin/