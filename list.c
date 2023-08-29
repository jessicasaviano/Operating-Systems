
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



void list_visit_items(list_t *l, void (*visitor)(void *v)){
    //printf('hi1');
    list_item_t *current = l->head;
    while(current != NULL){
        //printf('hi');
        visitor(current->datum);
        current = current->next;
    }
    
}
//change
void list_insert_tail(list_t *l, void *v) {
    int number = 0;
    list_item_t *item;
    item = (list_item_t*)malloc(sizeof(list_item_t));
    item->next = NULL;
    
    item->datum = (void*)malloc(sizeof(char)*42);
    strcpy(item->datum, (char*)v);
    
    if(l->head == NULL ){
        l->head = item;
    }
    else{
        l->tail->next = item;
    }
    l->tail = item;

    l->number+=1;
    

}

void list_remove_head(list_t *l){
    if(l->number != 0){
        list_item_t *temp = l->head->next;
        free(l->head->datum);
        free(l->head);
        l->head = temp;
         l->number -=1;
        
    }

   
}


