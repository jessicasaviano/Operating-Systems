
#ifndef LIST_H
#define LIST_H

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


void list_init(list_t *l, compare_func_t compare, datum_delete_func_t datum_delete);
void list_visit_items(list_t *l, void (*visitor)(void *v));
void list_insert_tail(list_t *l, void *v);
void list_remove_head(list_t *l);

#endif