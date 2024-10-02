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
    while (1) {
        cout << "1. DO\n"
            << "2. CLR data\n"
            << "3. EXIT\n";
        string action;
        cout << "Input: ";
        cin >> action;
        if (action == "3") exit(0);
        else if (action == "2") remove("data.bin");
        else if (action == "1") {

            srand(time(0));

            Data data("data.bin");
            const int N = data.n;

            float* A = data.dataA;
            float* B = data.dataB;

            float answerCPU;



            //CPU
            auto start = high_resolution_clock::now();
            answerCPU = CPUimplementation(A, B, N);
            auto stop = high_resolution_clock::now();
            int ms = duration_cast<milliseconds>(stop - start).count();
            int ns = duration_cast<nanoseconds>(stop - start).count();
            cout << "Num elements: " << N << endl;
            cout << "Answer (CPU): " << answerCPU << " time: " <<
                ms << "." << ns - ms * 1000000 << " ms" << endl;
            //cout<<" TEST " << ms <<" " << ns << " TEST" << endl;
            //GPU
            const int floatS = N * sizeof(float);
            float* answerGPU, * cudaA, * cudaB;
            float answerGGPU;

            cudaMalloc(&cudaA, floatS);
            cudaMalloc(&cudaB, floatS);
            cudaMalloc(&answerGPU, sizeof(float));

            cudaMemcpy(cudaA, A, floatS, cudaMemcpyHostToDevice);
            cudaMemcpy(cudaB, B, floatS, cudaMemcpyHostToDevice);

            cudaMemset(answerGPU, 0, sizeof(float));

            int number_of_blocks = (N + THREADS_PER_BLOCK - 1) / THREADS_PER_BLOCK;;

            //cout<<"THREADS_PER_BLOCK = "<<THREADS_PER_BLOCK<<endl;
            //cout<<"number_of_blocks = "<<number_of_blocks<<endl;
            cudaEvent_t startGPU, stopGPU;
            cudaEventCreate(&startGPU);
            cudaEventCreate(&stopGPU);

            cudaEventRecord(startGPU,0);
            //GPUatomicimplementation << < number_of_blocks, THREADS_PER_BLOCK, THREADS_PER_BLOCK * sizeof(float) >> > (cudaA, cudaB, answerGPU, N);
            GPUimplementation << < number_of_blocks, THREADS_PER_BLOCK, THREADS_PER_BLOCK * sizeof(float) >> > (cudaA, cudaB, answerGPU, N);
            cudaEventRecord(stopGPU,0);
            cudaEventSynchronize(stopGPU);

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
            cout << "Diff (CPU - GPU): " << answerCPU - answerGGPU << endl;
            cudaFree(cudaA);
            cudaFree(cudaB);
            cudaFree(answerGPU);
        }
        else
            cout << "Incorrect input:" << action;
    }
    return(0);
}
