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

    float *A = data.dataA;
    float *B = data.dataB;

    float answerCPU;

   

    //CPU
    auto start = high_resolution_clock::now();
    answerCPU = CPUimplementation(A, B, N);
    auto stop = high_resolution_clock::now();

    cout << "Answer (CPU): " << answerCPU << " time: " << duration_cast<milliseconds>(stop - start).count() << " ms" << endl;
    
    //GPU
    const int floatS = N*sizeof(float);
    float *answerGPU, *cudaA, *cudaB;
    float answerGGPU;

    cudaMalloc(&cudaA, floatS);
    cudaMalloc(&cudaB, floatS);
    cudaMalloc(&answerGPU, sizeof(float));

    cudaMemcpy(cudaA, A, floatS, cudaMemcpyHostToDevice);
    cudaMemcpy(cudaB, B, floatS, cudaMemcpyHostToDevice);

    cudaMemset(answerGPU, 0, sizeof(float));

    int number_of_blocks =  (N + THREADS_PER_BLOCK - 1) / THREADS_PER_BLOCK;;

    //cout<<"THREADS_PER_BLOCK = "<<THREADS_PER_BLOCK<<endl;
    //cout<<"number_of_blocks = "<<number_of_blocks<<endl;
    cudaEvent_t startGPU, stopGPU;
    cudaEventCreate(&startGPU);
    cudaEventCreate(&stopGPU);

    cudaEventRecord(startGPU);
    GPUimplementation<<< number_of_blocks, THREADS_PER_BLOCK, THREADS_PER_BLOCK * sizeof(float) >>>(cudaA, cudaB, answerGPU, N);
    //cudaDeviceSynchronize();

    cudaEventRecord(stopGPU);
    // Проверка ошибок
    cudaError_t error = cudaGetLastError();
    if (error != cudaSuccess) {
        std::cout << "CUDA error: " << cudaGetErrorString(error) << std::endl;
        return 1;
    }

    cudaMemcpy(&answerGGPU, answerGPU, sizeof(float), cudaMemcpyDeviceToHost);

    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, startGPU, stopGPU);

    cout << "Answer (GPU): " << answerGGPU << " time: " << milliseconds << " ms" << endl;
    cout << "Diff (CPU - GPU): " << answerCPU - answerGGPU<<endl;
    cudaFree(cudaA);
    cudaFree(cudaB);
    cudaFree(answerGPU);


    return(0);
}
