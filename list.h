
#ifndef LIST_H
#define LIST_H

typedef struct list {
    struct list * head;
    struct list * tail;
    unsigned int number;
    int (*compare)(const void *, const void *);
    void (*datum_delete)(void *);
} list_t;


typedef struct list_item {
   
    struct list_item * next;
    void *datum;
    
} list_item_t;

void list_init(list_t *l,int (*compare)(const void *key, const void *with),void (*datum_delete)(void *datum));
void print_string(void *v);
void list_visit_items(list_t *l, void (*visitor)(void *v));
void list_insert_tail(list_t *l, void *v);
void list_remove_head(list_t *l);

#endif