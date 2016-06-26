#include "stdio.h"
#include "stdlib.h"

#include "cuda.h"


#define W 4


int matrixMul_cpu(float *M, float *N, float *P)
{
  for(int i=0;i<W;i++)
    for(int j=0;j<W;j++)
    {
	float sum=0;
	for (int k=0;k<W;k++)
	  {
	    float a = *(M+i*W+k);
            float b = *(N+k*W+j);
	    sum += a * b;
	  }
	*(P+i*W+j) = sum;

    }	

    return 0;  
}

__global__ void matrixMul_gpu(float *M,float *N, float *P, int width)
{
	int i = threadIdx.y;
	int j = threadIdx.x;
	
	float sum =0;
        for (int k = 0;k<width;k++)
	  {
	     float a = *(M+i*width+k);
             float b = *(N+k*width+j);
             sum += a*b;
	  }  
	*(P+i*width+j) = sum;
}



int main()
{

	int sNo = 0;

	cudaSetDevice(sNo%8);

	int size = W*W*sizeof(float);
 
	float *M,*N,*P;
	float *d_M,*d_N,*d_P;

	M = (float *) malloc(size);
	N = (float *) malloc(size);
	P = (float *) malloc(size);
	
	cudaMalloc((void **)&d_M,size);
	cudaMalloc((void **)&d_N,size);
	cudaMalloc((void **)&d_P,size);
	

	for(int i=0;i<W*W;i++)
	{
	  *(M+i) = i;
          *(N+i) = i+1;
          *(P+i) = 0;
	}

	cudaMemcpy(d_M,M,size,cudaMemcpyHostToDevice);
	cudaMemcpy(d_N,N,size,cudaMemcpyHostToDevice);

	
	int err = matrixMul_cpu(M,N,P);

	dim3 threadPerBlock(W,W);

	matrixMul_gpu<<< 1, threadPerBlock  >>>(d_M,d_N,d_P,W);
        
        cudaMemcpy(P,d_P,size,cudaMemcpyDeviceToHost);


	for(int i=0;i<W;i++)
	{
	  for(int j=0;j<W;j++)
	     printf("%f ",*(P+i*W+j));
	  printf("\n");
	}

	free(M);free(N);free(P);
	cudaFree(d_M);cudaFree(d_N);cudaFree(d_P);

	return 0;

}
