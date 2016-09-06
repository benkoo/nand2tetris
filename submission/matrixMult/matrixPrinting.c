#include "stdio.h" 

#define  DEBUG 1
#define  MAX_SIZE_PRINTED = 4;
	
void printMatrix_w(float *Matrix, int W)
{

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
		
		printf("   The RIGHT_LOWER CORNER OF the %d * %d matrix\n", W, W);
		
		for(int i=W-MAX_SIZE_PRINTED;i<W;i++)
		{
		  for(int j=W-MAX_SIZE_PRINTED;j<W;j++)
		  	if (DEBUG) printf("%5.2f ",*(Matrix+i*W+j));

			if(DEBUG) printf("\n");
		}
		
	}
		
}