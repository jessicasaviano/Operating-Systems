#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

int main(int argc, char *argv[]) {

    FILE *f = fopen(argv[1], "r");
    char str[1024];
    while(!feof(f)){
        while(fgets(str, 1024,f ) != NULL){
            if(argv[2] == "echo"){ 
                int num = strlen(str);
                for (int i = 0; i < num; i++) {
                    unsigned char ans = str[i];
                        if(!isspace(ans)) {
                            printf(unsigned char ans);
                            
                                }
                                        }    
            }
            
        }
                                        fclose(f);    

    
            if(argv[2] == "tail"){
                //do something ("the inconjunction with functionanlity specified below")
    }
            if(argv[2] == "tail-remove"){
        
                //do something
    }


    }

    
return 0;
}

typedef struct list {
    struct list * head;
    struct list * tail;
    struct list * next;
    struct list * previous;
    int *data;
    int (*compare)(const void *, const void *);
    void (*datum_delete)(void *);
} list_t;

// constructor
void list_init(list_t *l, int (*compare)(const void *key, const void *with),void (*datum_delete)(void *datum)){
    l->head = NULL;
    l-> compare = compare;
    l->datum_delete = datum_delete;
    l -> tail = NULL;


}

void visitor(int *v){
    printf(*v); 

}
void list_visit_items(list_t *l, void (*visitor)(void *v)){
    list_t *current = l->head;
    while(current != NULL){
        visitor(current->data);
        current = current->next;
    }
}

void list_visit_tail(list_t *l, void *v) {
    // insert input when second parameter is tail
    // print contents of list 
}


//void list_insert_tail(list_t *l, void *v){

// tester comment
//}
