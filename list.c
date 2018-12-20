#include "list.h"

typedef struct _NodeList{
    void* data;
    struct _NodeList* next;
} NodeList;

struct _List{
    NodeList * node;
    bool ordened;
    bool copy;
    int size;
    
    destroy_elementlist_function_type destroy_element_function;
    copy_elementlist_function_type copy_element_function;
    print_elementlist_function_type print_element_function;
    cmp_elementlist_function_type cmp_element_function;
};


void linkedList_free_rec(NodeList*, List*);
void linkedList_free_no_node_rec(NodeList*, List*);
bool linkedList_set_ordened(List* l, bool ordened);
bool linkedList_set_copy(List* l, bool copy);
bool linkedList_set_size(List* l, int size);

NodeList * nodelinkedList_ini();


List* linkedList_ini(destroy_elementlist_function_type f1, copy_elementlist_function_type f2, print_elementlist_function_type f3, cmp_elementlist_function_type f4, bool copy){
    List* l = NULL;
    
    //if (!f1 || !f2 || !f3 || !f4)
    //    return NULL;
    
    l = (List*)malloc(sizeof(List));
    if (!l)
        return NULL;
    
    l->node = NULL;
    l->ordened = true;
    l->size = 0;
    l->copy = copy;
    
    l->destroy_element_function = f1;
    l->copy_element_function = f2;
    l->print_element_function = f3;
    l->cmp_element_function = f4;
    
    return l;
}


void linkedList_free_no_node(List* l){
    if (!l)
        return;
       
    if(linkedList_isEmpty(l) == false)
    	linkedList_free_no_node_rec(l->node->next, l);
    free(l);
    return;
}


void linkedList_free_no_node_rec(NodeList* node, List* l){
    if(node != l->node)
    	linkedList_free_no_node_rec(node->next, l);
    
    free(node);
    return;
}


void linkedList_free(List* l){
    if (!l)
        return;
       
    if(linkedList_isEmpty(l) == false)
        linkedList_free_rec(l->node->next, l);
    free(l);
    return;
}


void linkedList_free_rec(NodeList* node, List* l){
    if(node != l->node)
        linkedList_free_rec(node->next, l);
    
    if(node->data)
        l->destroy_element_function(node->data);
    free(node);
    return;
}


bool linkedList_insert_first(List* l, const void *e){
    NodeList * n = NULL;  /* Nuevo nodo a insertar */
    
    if (!l || !e)
        return false;
    
    n = nodelinkedList_ini();
    if (!n)
        return false;
    
    if(linkedList_is_copy(l) == true){
        n->data = l->copy_element_function(e);
        if (!n->data)
            return false;
    } else {
         n->data = (void*)e;
    }
    
    if(linkedList_isEmpty(l) == true){
        l->node = n;
        n->next = n;
        linkedList_set_size(l, linkedList_size(l)+1);
        return true;
    }

    
    n->next = l->node->next;
    l->node->next = n;
    linkedList_set_ordened(l, false);
    linkedList_set_size(l, linkedList_size(l)+1);
    return true;
}

bool linkedList_insert_last(List* l, const void *e){
    NodeList* n = NULL;
    
    if (!e || !l)
        return false;
    
    n = nodelinkedList_ini();
    if (!n)
        return false;

    if(linkedList_is_copy(l) == true){
        n->data = l->copy_element_function(e);
        if (!n->data)
            return false;
    } else {
         n->data = (void*)e;
    }

    
    if (linkedList_isEmpty(l) == true){
        n->next = n;
        l->node = n;
        linkedList_set_size(l, linkedList_size(l)+1);
        return true;
    }
    
    n->next = l->node->next;
    l->node->next = n;
    l->node = n;
    linkedList_set_ordened(l, false);
    linkedList_set_size(l, linkedList_size(l)+1);
    
    return true;
}


bool linkedList_inser_inOrder(List *l, const void *e){
    int i = 0;
    int comp = 0;
    NodeList* naux = NULL;
    NodeList* n = NULL;
    
    if(!l || !e)
        return false;
    
    if (linkedList_isEmpty(l) == true)
        return linkedList_insert_first(l, e);

    naux = l->node;
    for (i = 0; i < linkedList_size(l); i++){
        comp = l->cmp_element_function(naux->next->data, e);
        
        if(comp == 1){
            n = nodelinkedList_ini();
            if (!n)
                return false;
            
            if(linkedList_is_copy(l) == true){
                n->data = l->copy_element_function(e);
                if (!n->data)
                    return false;
            } else {
                 n->data = (void*)e;
            }
                    
            n->next = naux->next;
            naux->next = n;
            linkedList_set_size(l, linkedList_size(l)+1);
            
            return true;    
        }
        
        naux = naux->next;
    }
    
    return linkedList_insert_last(l, e);
}




void* linkedList_extract_first(List* l){
    if (!l || linkedList_isEmpty(l) == true)
        return NULL;
    
    return linkedList_extract(l, 0);
}

void* linkedList_extract_last(List* l){
    if (!l || linkedList_isEmpty(l) == true)
        return NULL;
    
    return linkedList_extract(l, linkedList_size(l)-1);
}


void* linkedList_extract(List* l, int position){
    int i;
    NodeList* n = NULL;
    NodeList* aux = NULL;
    void* e = NULL;
    
    if (!l || linkedList_isEmpty(l) == true || position < 0 || position >= linkedList_size(l))
        return NULL;
        
    for (i = 0, n = l->node->next, aux = l->node;  i != position; i++, aux = n, n = n->next);
    
    if(linkedList_is_copy(l) == true){
        e = l->copy_element_function(n->data);
        if (!e)
            return NULL;
    } else {
         e = n->data;
    }
        
    if(n == l->node)
        l->node = aux;
    
    aux->next = n->next;
    l->destroy_element_function(n->data);
    free(n);
    linkedList_set_size(l, linkedList_size(l)-1);

    return e;
}



void* linkedList_get_first(const List* l){
    if (!l || linkedList_isEmpty(l) == true)
        return NULL;
        
    return linkedList_get(l, 0);
}


void* linkedList_get_last(const List* l){
    if (!l || linkedList_isEmpty(l) == true)
        return NULL;
        
    return linkedList_get(l, linkedList_size(l)-1);
}


void* linkedList_get(const List* l, int position){
    int i;
    NodeList * n = NULL;
    
    if (!l || linkedList_isEmpty(l) == true || position < 0 || position >= linkedList_size(l))
        return NULL;
        
    for (i=0, n = l->node->next;  i != position ; i++, n = n->next);
    
    return n->data;
}



bool linkedList_remove_first(List* l){
    if (!l || linkedList_isEmpty(l) == true)
        return false;
    
    return linkedList_remove(l, 0);
}

bool linkedList_remove_last(List* l){
    if (!l || linkedList_isEmpty(l) == true)
        return false;
    
    return linkedList_remove(l, linkedList_size(l)-1);
}

bool linkedList_remove(List* l, int position){
    int i;
    NodeList* n = NULL;
    NodeList* aux = NULL;
    
    if (!l || linkedList_isEmpty(l) == true || position < 0 || position >= linkedList_size(l))
        return false;
        
    for (i = 0, n = l->node->next, aux = l->node;  i != position; i++, aux = n, n = n->next);
        
    if(n == l->node)
        l->node = aux;
    
    aux->next = n->next;
    l->destroy_element_function(n->data);
    free(n);
    linkedList_set_size(l, linkedList_size(l)-1);

    return true;
}



int linkedList_find(const List* l, const void* e){
    int i;
    NodeList* n = NULL;
    
    if (!l || !e)
        return -1;
        
    n = l->node;
    for (i = 0; i < linkedList_size(l); i++, n = n->next){
        if(l->cmp_element_function(n->next->data, e) == 0)
            return i;
    }
    return -1;
}




bool linkedList_isEmpty(const List* l){
    if (!l)
        return true;
    
    if (!l->node)
        return true;
    
    return false;    
}


bool linkedList_is_ordened(const List* l){
    if(!l)
        return false;
        
    return l->ordened;
}

bool linkedList_set_ordened(List* l, bool ordened){
    if(!l)
        return false;
        
    l->ordened = ordened;
    return true;
}



bool linkedList_is_copy(const List* l){
    if(!l)
        return false;
        
    return l->copy;
}

bool linkedList_set_copy(List* l, bool copy){
    if(!l)
        return false;
        
    l->copy = copy;
    return true;
}


int linkedList_size(const List* l){
    if (!l)
        return -1;
    
    return l->size;
}


bool linkedList_set_size(List* l, int size){
    if(!l || size < 0)
        return false;
        
    l->size = size;
    return true;
}



bool linkedList_print(FILE *fp, const List* l){
    NodeList * n = NULL;
    
    if(!fp || !l)
        return false;
        
    fprintf(fp, "[(%d)", linkedList_size(l));
    if(linkedList_isEmpty(l) == false){
    	n = l->node;
        do{
            fprintf(fp, " ");
            n = n->next;
            if(l->print_element_function(fp, n->data) == false)
                fprintf(fp, "(error)");
        }while(n != l->node);   
    }
    fprintf(fp, "]");
    
    return true;    
}

bool linkedList_print_alt(FILE *fp, const List* l){
    NodeList * n = NULL;
    
    if(!fp || !l)
        return false;

    if(linkedList_isEmpty(l) == false){
    	n = l->node;
        do{
            n = n->next;
            if(l->print_element_function(fp, n->data) == false)
                return false;
        }while(n != l->node);   
    }
    
    return true;    
}

/**************** NODELIST ESTRUCTURE FUNCTIONS **********************/

NodeList * nodelinkedList_ini(){
    NodeList* n = NULL;
    
    n = (NodeList*)malloc(sizeof(NodeList));
    if (!n)
        return NULL;
    
    n->data = NULL;
    n->next = NULL;
    return n;
}
