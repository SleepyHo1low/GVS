#include "imp.cuh"

__global__ void GPUimplementation(float* a,float* b, float* result, int N) {
    // Каждый поток вычисляет скалярное произведение для своей части массива
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < N) {
        atomicAdd(result, a[idx] * b[idx]);
    }
}

float CPUimplementation(float* a, float* b, int N)
{
    float temp = 0.0f;
    for (int i = 0; i < N; ++i)
    {
        temp += a[i] * b[i];
    }

    return temp;
}
