#ifndef __IMP_H_INCLUDED__
#define __IMP_H_INCLUDED__

#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#define TREADS_PER_BLOCK 256
float CPUimplementation(float* a, float* b, int N);
__global__ void GPUimplementation(float* a, float* b, float* result, int N);

#endif 
