#include "imp.cuh"

__global__ void GPUimplementation(float* a, float* b, float* result)
{
        int tid = threadIdx.x;
    int i = blockIdx.x * blockDim.x + tid;

    // Âû÷èñëåíèå ëîêàëüíîé ñóììû
    partialSums[tid] = a[i] * b[i];
    __syncthreads();

    // Ñóììèðîâàíèå ðåçóëüòàòîâ â ïðåäåëàõ áëîêà
    for (int s = blockDim.x / 2; s > 0; s >>= 1) {
        if (tid < s) {
            partialSums[tid] += partialSums[tid + s];
        }
        __syncthreads();
    }

    // Çàïèñü ðåçóëüòàòà â ãëîáàëüíóþ ïàìÿòü
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
