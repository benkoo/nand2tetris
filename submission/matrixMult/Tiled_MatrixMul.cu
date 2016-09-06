/**
 * Matrix multiplication Exercise : P = M . N.
 *
 * This program basically follows the tutorial in class.
 *
 * Given the 1024*1024 matrix test case, this program got the best performance
 * boost using TILE_WIDTH = 16. This was also suggested in the slide set.
 *
 * This exercise was executed on a MacBook Pro, with GeForce GT 650M
 * Using the CPU matrixMultiplication code, it takes about 18 seconds
 * Using this TILED approach, it only take about 0.13 ~0.15 seconds
 * 
 * See also:
 * Zhou Bin@ Nvidia & USTC, 2014, October, "CUDA Programming (2)" Lecture Slides
 * 
 *
 */

#include "stdio.h" 
#include "stdlib.h"

#include "cuda.h"
#include "cuda_runtime.h"


#define W 1024
#define TILE_WIDTH 16
#define DEBUG 1

void printMatrix(float *Matrix)
{
	const int MAX_SIZE_PRINTED = 4;
	
	printf("This is a %d by %d matrix.\n", W,W);
	
	if (W > MAX_SIZE_PRINTED) {
		printf("Actual displayed size is cut in 2 parts shown as");
		printf(" %d by %d matrix.\n", MAX_SIZE_PRINTED, MAX_SIZE_PRINTED);
		printf("   The Top_LEFT CORNER OF the %d * %d matrix:\n", W, W);
	}
	
	for(int i=0;i<W;i++)
	{
		  for(int j=0;j<W;j++)
		  	if(i < MAX_SIZE_PRINTED && j < MAX_SIZE_PRINTED){
		     if (DEBUG) printf("%5.2f ",*(Matrix+i*W+j));
			}
			if(i < MAX_SIZE_PRINTED && DEBUG) printf("\n");
	}
		
	if (W > MAX_SIZE_PRINTED){
		
		printf("   The LOWER_RIGHT CORNER OF the %d * %d matrix\n", W, W);
		
		for(int i=W-MAX_SIZE_PRINTED;i<W;i++)
		{
		  for(int j=W-MAX_SIZE_PRINTED;j<W;j++)
		  	if (DEBUG) printf("%5.2f ",*(Matrix+i*W+j));

			if(DEBUG) printf("\n");
		}
		
	}
		
}


/*
 *  This code is mostly copied from the slide set with some comments written by Ben Koo.
 *  
 *  In this test case, W = 1024, TILE_WIDTH = 16, making the dimGrid = 64 * 64
 *  Within each block, there are 16 * 16 threads.
 *
 *
 */
__global__ void matrixMulKernel_usingTile(float* Md, float* Nd, float* Pd, int Width)
{

	//This delcares the device memory as 16 * 16 float matrices
	__shared__ float Mds[TILE_WIDTH][TILE_WIDTH];
	__shared__ float Nds[TILE_WIDTH][TILE_WIDTH];

    // When W = 1024,t he block IDs (x * y) should be (64 * 64)
	int bx = blockIdx.x; int by = blockIdx.y;
	
    // When W = 1024, the thread IDs (x * y) should be (16 * 16)
	int tx = threadIdx.x; int ty = threadIdx.y;

	int Row = by * TILE_WIDTH + ty;
	int Col = bx * TILE_WIDTH + tx;



	float PValue = 0;
	
	// When W = 1024, m should go from 0 to 63
	for (int m =0; m < Width/TILE_WIDTH; ++m){
	  // The following memory access takes place in shared memory
	  Mds[ty][tx] = Md[Row*Width + (m*TILE_WIDTH + tx)];
	  Nds[ty][tx] = Nd[Col + (m*TILE_WIDTH+ty)*Width];
	  
	  //Make sure that all data are written in sync.
	  __syncthreads();

	  //Perform TILE level matrix multiplication and addition in synchrony.
	  for (int k = 0; k< TILE_WIDTH; ++k)	
		PValue += Mds[ty][k] * Nds[k][tx];
		__syncthreads();
	}
	
	//Take individually caldulated PValue and place it to the Pd (device memory array).
	Pd[Row * Width + Col] = PValue;
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


    //Populate initial values to the M, N and P matrices
	for(int i=0;i<W*W;i++)
	{
	  *(M+i) = i;
      *(N+i) = i+1;
      *(P+i) = 0;
	}

    cudaMemcpy(d_M, M,size,cudaMemcpyHostToDevice);
    cudaMemcpy(d_N, N,size,cudaMemcpyHostToDevice);
	
	//Starting from here, set up CUDA timing mechanism
	float time_elapsed = 0;
	
	cudaEvent_t start, stop;

	cudaEventCreate(&start);
	cudaEventCreate(&stop);

	cudaEventRecord(start, 0);

	dim3 dimGrid(W /TILE_WIDTH, W / TILE_WIDTH);
	dim3 dimBlock(TILE_WIDTH, TILE_WIDTH);
		
	matrixMulKernel_usingTile<<< dimGrid, dimBlock >>>(d_M,d_N,d_P,W);
	
    cudaEventRecord(stop,0);

	cudaEventSynchronize(start);

	cudaEventSynchronize(stop);

	//The following function returns time_elapsed using milli-seconds as time units
	cudaEventElapsedTime(&time_elapsed, start, stop);
	
	//Finished timing for CUDA execution

    //To display time_elapsed into a number, divide it by 1000 first.
	printf("\n\nGPU Elapsed Time:%f\n", time_elapsed/1000);
	
        
    cudaMemcpy(P,d_P,size,cudaMemcpyDeviceToHost);

	printMatrix(P);
	
	free(M);free(N);free(P);
	cudaFree(d_M);cudaFree(d_N);cudaFree(d_P);

	return 0;

}

