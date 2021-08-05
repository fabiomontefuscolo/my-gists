#include <getopt.h>
#include <regex.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void showHelp(char *biname) {
    printf("%s [-l length] [-f 'regex'] [-n]\n", biname);
    printf("    -l, --length\n");
    printf("        Password length\n");
    printf("    -f, --filter\n");
    printf("        Password characters will match filter pattern\n");
    printf("    -n\n");
    printf("        Do not output the trailing newline\n");
}

char* createPassword(int length, char* filter)
{
    int i;
    char ch[1];
    char *password;
    FILE *fp;
    regex_t regex;

    fp = fopen("/dev/urandom", "r");
    if(!fp) {
        return NULL;
    }

    password = malloc(length);
    regcomp(&regex, filter, 0);

    i = 0;
    while(i < length) {
        fread(&ch, 1, 1, fp);
        if(regexec(&regex, ch, (size_t) 0, NULL, 0) == 0) {
            password[ i ] = ch[0];
            i++;
        }
    }

    fclose(fp);
    return password;
}

int main(int argc, char **argv)
{
    // defaults
    int  password_length = 16;
    char password_filter[] = "[[:alnum:]]";
    char *password;

    char trailing_output[] = "\n";
    char opt_short[] = "hnf:l:";
    struct option opt_long[] = {
        {"filter"     , required_argument , 0, 'f'},
        {"help"       , no_argument       , 0, 'h'},
        {"length"     , required_argument , 0, 'l'},
        {"no-newline" , no_argument       , 0, 'n'},
        {0            , 0                 , 0,  0 }
    };

    int opt;
    while ((opt = getopt_long(argc, argv, opt_short, opt_long, NULL)) != -1) {
        switch(opt) {
            case 'f':
                strcpy(password_filter, optarg);
                break;
            case 'l':
                password_length = atoi(optarg);
                break;
            case 'n':
                strcpy(trailing_output, "");
                break;
            case 'h':
                showHelp("genpass");
                exit(-1);
        }
    }

    password = createPassword(password_length, password_filter);
    printf("%s%s", password, trailing_output);
    return 0;
}
