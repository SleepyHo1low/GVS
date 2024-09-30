#include "imp.cuh"

__global__ void GPUatomicimplementation(float* a,float* b, float* result, int N) {
    // Каждый поток вычисляет скалярное произведение для своей части массива
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < N) {
        atomicAdd(result, a[idx] * b[idx]);
    }
}

__global__ void GPUimplementation(float *a, float *b, float *result, int n) {
    extern __shared__ float sdata[];

    int tid = threadIdx.x;
    int i = blockIdx.x * blockDim.x + tid;

    if (i < n) {
        sdata[tid] = a[i] * b[i];
    } else {
        sdata[tid] = 0.0f;
    }
    __syncthreads();

    // Редукция в блоке (например, параллельное суммирование)
    for (int s = blockDim.x / 2; s > 0; s >>= 1) {
        if (tid < s) {
            sdata[tid] += sdata[tid + s];
        }
        __syncthreads();
    }

    if (tid == 0) {
        atomicAdd(c, sdata[0]);
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
