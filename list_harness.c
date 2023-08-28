#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

int main(int argc, char *argv[]){

    FILE *f = fopen(argv[1], "r");
    char str[41];
    int c;
    int count = 0;    
            if(argv[2] == "echo"){ 
                while((c = fgetc(f)) != EOF){
                   if (c == '\n') {
                    str[count] = '\0'; 
                    printf("%s\n", str);
                    count = 0;
        } else {
            str[count] = c;
            count++;
        }
                 
            } 
                           
    
            //if(argv[2] == "tail"){
                //do something ("the inconjunction with functionanlity specified below")
   // }
          //  if(argv[2] == "tail-remove"){
        
                //do something
   // }
            }
    
return 0;

}


//each line in each node
//when list reaches lenght of zero, now print empty
//remove three nodes at a time unitl empty for head
//if theres only 2 left, remove those two, and then print empty
//if the input file is compeltely empty just print empty and exit



//list item struct with next and prevous pointer (singly or doubly)

typedef struct list {
  struct list * head;
    struct list * tail;

    int (*compare)(const void *, const void *);
    void (*datum_delete)(void *);
} list_t;


typedef struct list_item {
   
    struct list_item * next;
    void *datum;
    
} list_item_t;

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
    list_t *current = l->head;
    list_item_t *next;
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
    v = malloc();
    strncpy(v, str);

}


//free in remove section!!