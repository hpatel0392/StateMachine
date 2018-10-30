
char tennis(char);

__kernel void tennis_kernel(global char* restrict A, global char* restrict score)

{
	int i;
	
	for(i = 0; i < 51; i++){
		score[i] = tennis(A[i]);
	}
	
}
