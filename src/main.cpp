//
// Created by gyb on 2021/11/15.
//

#include "syntax.cpp"

int main(int argc, char **argv)
{
    if(argc != 2) {
        fprintf(stderr, "Usage: %s <file_path>\n", argv[0]);
        exit(-1);
    }
    else if(!(yyin = fopen(argv[1], "r"))) {
        perror(argv[1]);
        exit(-1);
    }

    /* get the output-file name */
    strcpy(log_file_name, argv[1]);
    char *dot = strrchr(log_file_name, '.');
    strcpy(dot, ".out");
    FILE *fp = fopen(log_file_name, "w");
    fclose(fp);

    yyparse();

    if(!error_occur){
        print_parsetree(head,0);
    }
    return 0;
}