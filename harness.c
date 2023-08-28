#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "list.h"



void visit(void *v){
    printf("%s",(char *)v); 
//printf("string");
}

int main(int argc, char ** argv){
    if (argc != 3) {
        printf("ERROR\n");
        return 1;
    }
    

    if(strcmp("echo", argv[2])== 0){
        FILE *file = fopen(argv[1], "r");
        char line[41];
        while(fgets(line, 41, file) != NULL  ) {
            //printf("%s", line);
    }


    }

    if(strcmp("tail", argv[2])== 0){
        //printf("l");
        // //do stuff
        FILE *file = fopen(argv[1], "r");
        //printf("hi");
        list_t *singly = (list_t*) malloc(sizeof(list_t));
        //printf("hi2");
        singly ->head = NULL;
        singly->tail = NULL;
        char line[42];
        //printf("hi3");
        while(fgets(line, 42, file) != NULL) {
            //printf("hi4");
            //printf(line);
            list_insert_tail(singly, line);
        }

        list_visit_items(singly, visit);
        //printf("hi");
        //printf("      ");


    }

    if(strcmp("tail-remove", argv[2])== 0){
        //do stuff
        FILE *file = fopen(argv[1], "r");
        //printf("hi");
        list_t *singly = (list_t*) malloc(sizeof(list_t));
        //printf("hi2");
        singly ->head = NULL;
        singly->tail = NULL;
        char line[42];
        //printf("hi3");
        while(fgets(line, 42, file) != NULL) {
            //printf("hi4");
            //printf(line);
            list_insert_tail(singly, line);
        }


    }


}

