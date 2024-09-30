#ifndef __IMP_H_INCLUDED__
#define __IMP_H_INCLUDED__

#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#define THREADS_PER_BLOCK 256
//#define BLOCKS_PER_GRID ((1000000000 + THREADS_PER_BLOCK - 1) / THREADS_PER_BLOCK)
__shared__ float partialSums[THREADS_PER_BLOCK];
float CPUimplementation(float* a, float* b, int N);
__global__ void GPUimplementation(float* a, float* b, float* result);

#endif 
