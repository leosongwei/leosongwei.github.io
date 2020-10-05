#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>

int main()
{
	int* arrays[1000];
	for(int i=0; i<1000; i++){
		arrays[i] = malloc(sizeof(uint32_t)*1000*1000);
	}

	clock_t start = clock();

	for(int i=0; i<1000; i++){
		int* array = arrays[i];
		memset(array, 0xF, 4*1000*1000);
		/*
		for(int j=0; j<1000; j++){
			for(int k=0; k<1000; k++){
				array[j*1000 + k] = 0xF;
			}
		}
		*/
	}

	clock_t end = clock();

	double time = ((double)(end - start)) / CLOCKS_PER_SEC;
	printf("time used: %f", time);
	return 0;
}
