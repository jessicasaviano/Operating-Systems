#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "list.h"




int main(int argc, char ** argv){
    if (argc != 3) {
        printf("ERROR");
        return 1;
    }
    

    if(strcmp("echo", argv[2])== 0){
        FILE *file = fopen(argv[1], "r");
        char line[41];
        while(fgets(line, 41, file) != NULL) {
            printf("%s", line);
    }


    }

    if(strcmp("tail", argv[2])== 0){
        //do stuff


    }

    if(strcmp("tail-remove", argv[2])== 0){
        //do stuff


    }


}

