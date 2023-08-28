
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "list.h"



 //constructor
void list_init(list_t *l, int (*compare)(const void *key, const void *with),void (*datum_delete)(void *datum)){
    list_t *mylist;
    mylist = (list_t*)malloc(sizeof(mylist));
    l->head = NULL;
    l-> compare = compare;
    l->datum_delete = datum_delete;
    l -> tail = NULL;

}

void print_string(void *v){
    printf('%s\n',(char *)v); 

}


void list_visit_items(list_t *l, void (*visitor)(void *v)){
    list_item_t *current = l->head;
    while(current != NULL){
        print_string(current->datum);
        current = current-> next;
    }
}

void list_insert_tail(list_t *l, void *v) {
    // insert input when second parameter is tail
    // print contents of list 
    list_item_t *item;
    item = (list_item_t*)malloc(sizeof(list_item_t));
    item->next = NULL;
    l->tail = item;
    item->datum = (void*)malloc(sizeof(char)*41);
    strcpy(item->datum, v);
    //l->tail->next = item;
    l->tail = item;
    l->number+=1;

}

//void list_remove_head(list_t *l){



//}


