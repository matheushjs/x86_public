#include <stdio.h>
#include <stdlib.h>

typedef struct _Node Node;
struct _Node {
	int key;
	Node *next;
	Node *prev;
};

Node *hashTable[16] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

Node *node_new(){
	Node *n = malloc(sizeof(Node));
	n->next = 0;
	n->prev = 0;
	return n; 
}

int hashing(int num){
	return (int)(num & 0xF); //Modulo 16 (Pega somente o ultimos 4 bits de num
}

//Adiciona 'key' na hashTable
void hash_table_insert(int key){
	Node *prev, *curr, *new;
	int index;
	
	index = hashing(key);

	prev = NULL;
	curr = hashTable[index];
	while(curr != NULL && curr->key < key){
		prev = curr;
		curr = curr->next;
	}

	if(curr != NULL && curr->key == key)
		return; //Valor repetido, nao quero.

	new = node_new();
	new->key = key;
	new->next = curr;
	new->prev = prev;
	if(curr != NULL)
		curr->prev = new;
	if(prev != NULL){
		prev->next = new;
	} else
		hashTable[index] = new;
}

//Busca 'key'
int hash_table_search(int key){
	Node *curr;
	int index = hashing(key);

	curr = hashTable[index];

	while(curr != NULL && curr->key <= key){
		if(key == curr->key)
			return index;
		curr = curr->next;
	}
	return -1;
}

//Remove 'key'
void hash_table_remove(int key){
	Node *curr, *prev; 
	int index = hashing(key);

	prev = NULL;
	curr = hashTable[index];
	while(curr != NULL){
		if(curr->key > key) break;
		if(curr->key == key){
			Node *next = curr->next;
			if(next != NULL)
				next->prev = prev;
			if(prev != NULL){
				prev->next = next;
			} else {
				hashTable[index] = next;
			}
			return;
		}
		prev = curr;
		curr = curr->next;
	}
}

//Printa a tabela
void hash_table_print(){
	int i;

	i = 0;
	do {
		Node *node = hashTable[i];
		printf("%d: ", i);
		while(node != NULL){
			printf("%d ", node->key);
			node = node->next;
		}
		printf("\n");
		i++;
	} while(i != 16);
}

int main(int argc, char *argv[]){
	int i;

	for(i = 0; i < 150; i++)
		hash_table_insert(i);

	hash_table_print();
	for(i = 99; i >= 0; i--)
		hash_table_insert(i);

	hash_table_print();
	for(i = 149; i >= 100; i--)
		hash_table_remove(i);

	hash_table_print();
	for(i = 149; i >= 100; i--){
		if(hash_table_search(i) == -1){
			printf("Could not find %d\n", i);
		} else printf("Found %d\n", i);
	}

	hash_table_print();


	printf("%d\n", (int) '\t');
}
