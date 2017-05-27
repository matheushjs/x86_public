#include <stdio.h>
#include <stdlib.h>

typedef struct _Node Node;
struct _Node {
	int key;
	Node *next;
};

Node **hashTable;
int hashSize;
int hashCount;

void hash_table_set(){
	Node **aux = hashTable + hashSize - 1;
	do {
		*aux = NULL;
		aux--;
	} while(aux >= hashTable);
}

void hash_table_init(){
	hashSize = 0x10; //Valor inicial 16. Sempre dobra. Tem sempre que ser potencia de 2 (ver hashing())
	hashCount = 0;
	hashTable = malloc(sizeof(Node *) * hashSize);
	hash_table_set();
}

Node *node_new(){
	Node *n = malloc(sizeof(Node));
	n->next = 0;
	return n; 
}

int hashing(int num){
	return (int)(num & (hashSize-1)); // Assume-se hashSize como potencia de 2.
}

//Adiciona 'key' na hashTable
void hash_table_insert_op(int key, int inc){
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
	if(prev != NULL){
		prev->next = new;
	} else
		hashTable[index] = new;

	if(inc){
		void hash_table_grow(void); //OMG declaration
		hashCount++;
		if( (hashCount / (double) hashSize) > 0.66 ) // Cresce em 66% da capacidade
			hash_table_grow();
	}
}

// Wrapper para a funcao acima.
void hash_table_insert(int key){ hash_table_insert_op(key, 1); }

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
			if(prev != NULL){
				prev->next = next;
			} else {
				hashTable[index] = next;
			}
			free(curr);
			hashCount--;
			void hash_table_shrink(void); //OMG declaration
			if( (hashCount / (double) hashSize) < 0.30 ) // Decresce em 30% da capacidade
				hash_table_shrink();
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
	} while(i != hashSize);
}

void hash_table_free(){
	int i;

	i = 0;
	do{
		Node *node = hashTable[i];
		while(node != NULL){
			Node *aux = node->next;
			free(node);
			node = aux;
		}
		i++;
	} while(i != hashSize);

	free(hashTable);
}

void hash_table_grow(){
	Node **old = hashTable;
	int oldSize = hashSize;
	int oldCount = hashCount;

	hashSize <<= 1;
	hashTable = malloc(sizeof(Node *) * hashSize);
	hash_table_set();
	
	printf("Growing to %d\n", hashSize);

	int i = 0;
	do {
		Node *node = old[i];
		while(node != NULL){
			hash_table_insert_op(node->key, 0);

			Node *aux = node->next;
			free(node);
			node = aux;
		}
		i++;
	} while(i != oldSize);
	
	free(old);
	hashCount = oldCount;
}

void hash_table_shrink(){
	if(hashSize == 0x10) return;

	int oldSize = hashSize;
	Node **old = hashTable;
	int oldCount = hashCount;

	hashSize >>= 1;
	hashTable = malloc(sizeof(Node *) * hashSize);
	hash_table_set();

	printf("Shrinking to %d\n", hashSize);

	int i = 0;
	do {
		Node *node = old[i];
		while(node != NULL){
			hash_table_insert_op(node->key, 0);

			Node *aux = node->next;
			free(node);
			node = aux;
		}
		i++;
	} while(i != oldSize);

	free(old);
	hashCount = oldCount;
}

int main(int argc, char *argv[]){
	int i;

	hash_table_init();

	for(i = 0; i < 150; i++)
		hash_table_insert(i*7);

	for(i = 99; i >= 0; i--)
		hash_table_insert(i*7);

	for(i = 149; i >= 100; i--)
		hash_table_remove(i*7);

	for(i = 103; i >= 96; i--){
		if(hash_table_search(i) == -1){
			printf("Could not find %d\n", i);
		} else printf("Found %d\n", i);
	}

	hash_table_print();

	printf("%d\n", hashCount);

	hash_table_free();
}
