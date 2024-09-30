#include "imp.cuh"

__global__ void GPUimplementation(const float* a, const float* b, float* result, int N) {
    // Каждая нить обрабатывает несколько элементов
    int tid = threadIdx.x;
    int blockDim = blockDim.x;
    int i = blockIdx.x * blockDim + tid;

    // Разделяемая память для блока
    __shared__ float shared_a[blockDim];
    __shared__ float shared_b[blockDim];

    // Копирование данных из глобальной памяти в разделяемую
    shared_a[tid] = a[i];
    shared_b[tid] = b[i];
    __syncthreads();

    // Вычисление локальной суммы
    float sum = 0;
    for (int stride = blockDim/2; stride > 0; stride >>= 1) {
        if (tid < stride) {
            sum += shared_a[tid+stride] * shared_b[tid+stride];
        }
        __syncthreads();
    }

    // Запись результата в глобальную память
    if (tid == 0) {
        atomicAdd(result, sum);
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
