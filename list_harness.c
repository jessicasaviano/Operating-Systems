#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

int main(int argc, char *argv[]) {

    FILE *f = fopen(argv[1], "r");
    char str[41];
    int c;
    int count = 0;
    
        //fgetc in  aloop, filing in a buffer, fscanf, read until newline, then print buffer, then go do back to top of loop and repeat
        
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
            
            
    }                        
    
            //if(argv[2] == "tail"){
                //do something ("the inconjunction with functionanlity specified below")
   // }
          //  if(argv[2] == "tail-remove"){
        
                //do something
   // }


    

    
return 0;
}
//list item struct with next and prevous pointer (singly or doubly)

//typedef struct list {
  //  struct list * head;
    //struct list * tail;

    //int (*compare)(const void *, const void *);
    //void (*datum_delete)(void *);
//} list_t;


//typedef struct list_item {
   
  //  struct list_item * next;
    //void *datum;
    
//} list_item_t;

// constructor
/*
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
    while(current != NULL){
        print_string(current->datum);
        current = current->next;
    }
}

void list_insert_tail(list_t *l, void *v) {
    // insert input when second parameter is tail
    // print contents of list 
}
*/

//void list_insert_tail(list_t *l, void *v){

// tester comment
//}

//free in remove section!!