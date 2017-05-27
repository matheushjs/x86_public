#define ELF_DIE(X) fprintf(stdout, "%s:%s:%d - %s", __FILE__, __func__, __LINE__, X), exit(EXIT_FAILURE)
#define ELF_MAX(X,Y) ((X)>(Y)?X:Y)
#define ELF_MIN(X,Y) ((X)<(Y)?X:Y)
#define ELF_ABS(X) ((X)<0?-(X):X)
#define ELF_MEDIAN(X, Y, Z) (X<=Y?(X>=Z?X:(Z<=Y?Z:Y)):(Y>=Z?Y:(X<=Z?X:Z)))

static
void partition_ascend(int *vec, int left, int right, int *left_of_mid, int *right_of_mid){
	int pivot, aux;

	pivot = ELF_MEDIAN(vec[left], vec[right], vec[(left+right)/2]);
	
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
void quicksort_op_ascend(int *vec, int left, int right){
	int i, j;

	if(right <= left) return;
	partition_ascend(vec, left, right, &i, &j);
	quicksort_op_ascend(vec, left, i);
	quicksort_op_ascend(vec, j, right);
}

// Documented in header file.
void elfIntVector_qsort_ascend(ElfIntVector *elf){
	if(!elf) ELF_DIE("NULL pointer received!");
	if(elf->size <= 1) return;

	quicksort_op_ascend(elf->vector, 0, elf->size - 1, NULL);
}
