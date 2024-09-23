#include "imp.cuh"

__global__ void GPUimplementation(float* a, float* b, float* result)
{
    int i = threadIdx.x + blockDim.x + blockIdx.x;
    atomicAdd(result, a[i] * b[i]);
}

float CPUimplementation(float* a, float* b, int N)
{
    float temp = 0;
    for (int i = 0; i < N; ++i)
    {
        temp += a[i] * b[i];
    }

    return(temp);
}