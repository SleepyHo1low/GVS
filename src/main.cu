#include <stdio.h>
#include <iostream>
#include <chrono>
#include <ctime>
#include <curand.h>
#include "imp.cuh"
#include "data.cpp"
using namespace std;
using namespace std::chrono;


int main()
{
    srand(time(0));

    Data data("/content/Data/data.bin");
    const int N = data.n;
    const int floatS = N*sizeof(float);

    float *A = data.dataA;
    float *B = data.dataB;

    float answerCPU;

   

    //CPU
    auto start = high_resolution_clock::now();
    answerCPU = CPUimplementation(A, B, N);
    auto stop = high_resolution_clock::now();

    cout << "Answer (CPU): " << answerCPU << " time: " << duration_cast<milliseconds>(stop - start).count() << " ms" << endl;
    
    //GPU
    float *answerGPU = new float(), *answerGGPU = new float();
    *answerGPU = 0;
    *answerGGPU = 0;
    float* cudaA;
    float* cudaB;

    cudaMalloc(&cudaA, floatS);
    cudaMalloc(&cudaB, floatS);
    cudaMalloc(&answerGPU, sizeof(float));

    cudaMemcpy(cudaA, A, floatS, cudaMemcpyHostToDevice);
    cudaMemcpy(cudaB, B, floatS, cudaMemcpyHostToDevice);

    const int block_size = 256;
    int number_of_blocks = N/block_size + 1;

    cudaEvent_t startGPU, stopGPU;
    cudaEventCreate(&startGPU);
    cudaEventCreate(&stopGPU);

    cudaEventRecord(startGPU);
    GPUimplementation<<< number_of_blocks, block_size >>>(cudaA, cudaB, answerGPU);
    cudaDeviceSynchronize();

    // Проверка ошибок
    cudaError_t error = cudaGetLastError();
    if (error != cudaSuccess) {
        std::cout << "CUDA error: " << cudaGetErrorString(error) << std::endl;
        return 1;
    }
    cudaEventRecord(stopGPU);

    cudaMemcpy(answerGGPU, answerGPU, sizeof(float), cudaMemcpyDeviceToHost);

    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, startGPU, stopGPU);

    cout << "Answer (GPU): " << *answerGGPU << " time: " << milliseconds << " ms" << endl;

    cudaFree(cudaA);
    cudaFree(cudaB);
    cudaFree(answerGPU);



    return(0);
}
