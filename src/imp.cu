#include "imp.cuh"
__shared__ float partialSums[THREADS_PER_BLOCK];

__global__ void GPUimplementation(float* a, float* b, float* result)
{
        int tid = threadIdx.x;
    int i = blockIdx.x * blockDim.x + tid;

    // Вычисление локальной суммы
    partialSums[tid] = a[i] * b[i];
    __syncthreads();

    // Суммирование результатов в пределах блока
    for (int s = blockDim.x / 2; s > 0; s >>= 1) {
        if (tid < s) {
            partialSums[tid] += partialSums[tid + s];
        }
        __syncthreads();
    }

    // Запись результата в глобальную память
    if (tid == 0) {
        atomicAdd(result, partialSums[0]);
    }
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
