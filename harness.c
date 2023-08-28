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
    FILE *file = fopen(argv[1], "r");
    if(strcmp("echo", argv[2])== 0){
        printf("hi");


    }

    if(strcmp("tail", argv[2])== 0){
        //do stuff


    }

    if(strcmp("tail-remove", argv[2])== 0){
        //do stuff


    }


}

