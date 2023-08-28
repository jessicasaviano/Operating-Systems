
#ifndef LIST_H
#define LIST_H

typedef struct list {
    struct list_item * head;
    struct list_item * tail;
    
    int (*compare)(const void *, const void *);
    void (*datum_delete)(void *);
} list_t;
//

typedef struct list_item {
    struct list_item * next;
    void *datum;
    
} list_item_t;



#endif