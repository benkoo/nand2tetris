#include "stdio.h" 
#include "stdlib.h"

#include "cuda.h"
#include "cuda_runtime.h"

#define W 8
#define TILE_WIDTH 2
#define DEBUG 1

void printMatrix(float *Matrix)
{
		for(int i=0;i<W;i++)
		{
		  for(int j=0;j<W;j++)
		     if (DEBUG) printf("%5.2f ",*(Matrix+i*W+j));
		  if (DEBUG) printf("\n");
		}
}

//This is for transposing a matrix
__global__ void transposeMatrix(float *oData, float *iData, int width, int height)
{
	int xIndex = blockIdx.x *TILE_WIDTH + threadIdx.x;
	int yIndex = blockIdx.y *TILE_WIDTH + threadIdx.y;

        int index_in  = xIndex + width  * yIndex;
	int index_out = yIndex + height * xIndex; 

	oData[index_out] = iData[index_in];

}

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

__global__ void MatrixMulKernel_basic(float* Md, float* Nd, float* Pd, int Width)
{
  int Row = blockIdx.y * blockDim.y + threadIdx.y;
  int Col = blockIdx.x * blockDim.x + threadIdx.x;
  
  float Pvalue = 0;
  if(Row < Width && Col < Width){
  for (int k = 0; k < Width; ++k)
	Pvalue += Md[Row * Width + k] * Nd[k * Width + Col];
	
  Pd[Row * Width + Col] = Pvalue;
  }
}

//Matrix Multiplication Kernel
__global__ void matrixMulKernel_1(float* Md, float* Nd, float* Pd, int Width)
{
	//2D Thread ID

	int tx = threadIdx.x;
	int ty = threadIdx.y;

	//Pvalue stores the Pd value computed by the thread
	float Pvalue = 0;

	for (int k = 0; k < Width; k++)
	{
	    float Mdelement = Md[ty * W + k];
	    float Ndelement = Nd[k * W + tx];
	    Pvalue += Mdelement * Ndelement;
	}	

	//Write the matrix to device memory each thread writes one element
	Pd[ty*Width + tx] = Pvalue;
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

__global__ void matrixMulKernel(float* Md, float* Nd, float* Pd, int Width)
{

	__shared__ float Mds[TILE_WIDTH][TILE_WIDTH];
	__shared__ float Nds[TILE_WIDTH][TILE_WIDTH];

	int bx = blockIdx.x; int by = blockIdx.y;
	int tx = threadIdx.x; int ty = threadIdx.y;

	int Row = by * TILE_WIDTH + ty;
	int Col = bx * TILE_WIDTH + tx;



	float PValue = 0;
	for (int m =0; m < Width/TILE_WIDTH; ++m){
	  Mds[ty][tx] = Md[Row*Width + (m*TILE_WIDTH + tx)];
	  Nds[ty][tx] = Nd[Col + (m*TILE_WIDTH+ty)*Width];
	  __syncthreads();

	  for (int k = 0; k< TILE_WIDTH; ++k)	
		PValue += Mds[ty][k] * Nds[k][tx];
		__syncthreads();
	}
	Pd[Row * Width + Col] = PValue;
}
 
 
int main()
{
	int sNo = 0;
	cudaSetDevice(sNo%8);

	int size = W*W*sizeof(float);
 
	float *M,*N,*P,*T;
	float *d_M,*d_N,*d_P;

	M = (float *) malloc(size);
	N = (float *) malloc(size);
	P = (float *) malloc(size);
	T = (float *) malloc(size);

	cudaMalloc((void **)&d_M,size);
	cudaMalloc((void **)&d_N,size);
	cudaMalloc((void **)&d_P,size);


	for(int i=0;i<W*W;i++)
	{
	  *(M+i) = i;
      *(N+i) = i+1;
      *(P+i) = 0;
      *(T+i) = 0;

	  if (DEBUG) printf("%f, %f ", *(M+i), *(N+i));
	  
	}
	  if (DEBUG) printf("\n");
	
	clock_t startT, finishT;

	startT = clock();
	int err = matrixMul_cpu(M,N,P);
	finishT = clock();
        printf("CPU elapsed time:%f\n\n", (float)(finishT - startT)/CLOCKS_PER_SEC);
		
	printMatrix(P);


    cudaMemcpy(d_M, M,size,cudaMemcpyHostToDevice);
    cudaMemcpy(d_N, N,size,cudaMemcpyHostToDevice);
	
	//Starting from here, set up the timing for CUDA devices
	float time_elapsed = 0;
	
	cudaEvent_t start, stop;

	cudaEventCreate(&start);
	cudaEventCreate(&stop);

	cudaEventRecord(start, 0);

	dim3 dimGrid(W /TILE_WIDTH, W / TILE_WIDTH);
	dim3 dimBlock(TILE_WIDTH, TILE_WIDTH);
		
	matrixMulKernel<<< dimGrid, dimBlock >>>(d_M,d_N,d_P,W);
	
    cudaEventRecord(stop,0);

	cudaEventSynchronize(start);

	cudaEventSynchronize(stop);

	cudaEventElapsedTime(&time_elapsed, start, stop);
	
	//Finished timing for CUDA execution

	printf("GPU Elapsed Time:%f\n", time_elapsed);
	
        
    cudaMemcpy(P,d_P,size,cudaMemcpyDeviceToHost);

	printMatrix(P);
	
	free(M);free(N);free(P);
	cudaFree(d_M);cudaFree(d_N);cudaFree(d_P);

	return 0;

}

