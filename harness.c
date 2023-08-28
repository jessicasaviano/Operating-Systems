#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "list.c"



int main(int argc, char ** argv){
    File *file = fopen(argv[1], "r");
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

