
#ifndef LIST_H
#define LIST_H

typedef struct list {
    struct list * head;
    struct list * tail;
    unsigned int number;
    int (*compare)(const void *, const void *);
    void (*datum_delete)(void *);
} list_t;
//

typedef struct list_item {
    struct list_item * next;
    void *datum;
    
} list_item_t;



#endif