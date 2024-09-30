#include "imp.cuh"

__global__ void GPUimplementation(float* a, float* b, float* result, int N)
{
    // Инициализация разделяемой памяти нулями
    partialSums[threadIdx.x] = 0.0f;

    __syncthreads();
    int tid = threadIdx.x;
    int i = blockIdx.x * blockDim.x + tid;

    if( i<N){
        // Загрузка данных из глобальной памяти в разделяемую
        float a_local = a[i];
        float b_local = b[i];

        // Вычисление локальной суммы
        partialSums[tid] = a_local * b_local;

        // Суммирование результатов в пределах блока
        __syncthreads();
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
