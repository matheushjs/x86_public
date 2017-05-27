#include <stdio.h>
#include <stdlib.h>

#define MEDIAN(X, Y, Z) (X<=Y?(X>=Z?X:(Z<=Y?Z:Y)):(Y>=Z?Y:(X<=Z?X:Z)))

static
void partition(int *vec, int left, int right, int *left_of_mid, int *right_of_mid){
	int pivot, aux;

	//pivot = MEDIAN(vec[left], vec[right], vec[(left+right)/2]);
	pivot = vec[(left+right) >> 1];

	while(left <= right){
		while(vec[left] < pivot) left++;
		while(vec[right] > pivot) right--;
		if(left > right) break;
		
		// Swap
		aux = vec[left];
		vec[left] = vec[right];
		vec[right] = aux;

		left++;
		right--;
	}

	// left/right inverted positions after applying the partition procedure.
	*left_of_mid = right;
	*right_of_mid = left;
}

// Recursive part of quicksort.
static
void quicksort(int *vec, int left, int right){
	int i, j;

	if(right <= left) return;
	partition(vec, left, right, &i, &j);
	quicksort(vec, left, i);
	quicksort(vec, j, right);
}

int main(int argc, char *argv[]){
	int vector[1000];
	int i, size = 0;

	while(scanf("%d", &vector[size]) == 1)
		size++;

	quicksort(vector, 0, size-1);

	for(i = 0; i < size; i++)
		printf("%d ", vector[i]);
	printf("\n");

	return 0;
}
