#include <stdio.h>
#include <iostream>
#include <chrono>
#include <ctime>
#include <curand.h>
#include "imp.cuh"

using namespace std;
using namespace std::chrono;

void fillArrays(float* a, float* b, int N)
{
    for (int i = 0; i < N; ++i)
    {
        a[i] = (float)(rand()) / (float)(RAND_MAX);
        b[i] = (float)(rand()) / (float)(RAND_MAX);
    }
}

int main()
{
    srand(time(0));

    //Ðàçìåð âåêòîðîâ
    const int N = 100000;
    const long int floatS = N*sizeof(float);

    float *A = new float[N];
    float *B = new float[N];

    float answerCPU, answerGPU = 0, answerGGPU = -1;

    fillArrays(A, B, N);

    //CPU
    auto start = high_resolution_clock::now();
    answerCPU = CPUimplementation(A, B, N);
    auto stop = high_resolution_clock::now();

    cout << "Answer (CPU): " << answerCPU << " time: " << duration_cast<milliseconds>(stop - start).count() << " ms" << endl;
    
    //GPU

    float* cudaA;
    float* cudaB;

    cudaMalloc(cudaA, floatS);
    cudaMalloc(cudaB, floatS);
    cudaMalloc(answerGPU, sizeof(float));

    //Êîïèðóåì ìàññèâû íà âèäþõó
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

    cudaEventRecord(stopGPU);

    cudaMemcpy(answerGGPU, answerGPU, sizeof(float), cudaMemcpyDeviceToHost);

    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, startGPU, stopGPU);

    cout << "Answer (GPU): " << answerGGPU << " time: " << milliseconds << " ms" << endl;

    cudaFree(cudaA);
    cudaFree(cudaB);
    cudaFree(answerGPU);

    delete[] A;
    delete[] B;

    return(0);
}
