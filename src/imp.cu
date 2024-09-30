#include "imp.cuh"

__global__ void GPUimplementation(float* a, float* b, float* result, int N)
{
    __shared__ float partialSums[THREADS_PER_BLOCK];

    int tid = threadIdx.x;
    int i = blockIdx.x * blockDim.x + tid;

    // Инициализация разделяемой памяти нулями
    partialSums[tid] = 0.0f;

    if (i < N) {
        // Вычисление локальной суммы
        partialSums[tid] = a[i] * b[i];

        __syncthreads();

        // Суммирование результатов в пределах блока
        if (tid == 0) {
            int sum = 0;
            for (int i = 0; i < THREADS_PER_BLOCK; i++) {
                sum += partialSums[i];
            }
            __syncthreads(); // Синхронизация перед атомарной операцией
            atomicAdd(result, sum);
        }
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
