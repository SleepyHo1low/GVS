#include "imp.cuh"
#include <iostream>
#include <ctime>
#include <random>

using namespace std;

void tests(int N){
  float *A = new float[N];
  float *B = new float[N];
  float *answerGPU = new float();
  float *answerGGPU = new float();
  *answerGPU = 0;
  *answerGGPU = 0;

  float mean = 0.0;      
  float stddev = 2.0;

  random_device rd;
  mt19937 gen(rd()); 
  normal_distribution<double> dist(mean, stddev);

  for (int i = 0; i < N; ++i) {
      A[i] = dist(gen);
      B[i] = dist(gen);
  }


  float answerCPU = CPUimplementation(A, B, N); // Вычисления на CPU

  float *cudaA, *cudaB; // Вычисления на GPU
  cudaMalloc(&cudaA, N * sizeof(float));
  cudaMalloc(&cudaB, N * sizeof(float));
  cudaMalloc(&answerGPU, sizeof(float));

  cudaMemcpy(cudaA, A, N * sizeof(float), cudaMemcpyHostToDevice);
  cudaMemcpy(cudaB, B, N * sizeof(float), cudaMemcpyHostToDevice);

  const int block_size = 256;
  int number_of_blocks = N/block_size + 1;

  GPUimplementation<<<number_of_blocks, block_size>>>(cudaA, cudaB, answerGPU);
  cudaDeviceSynchronize();

  cudaMemcpy(answerGGPU, answerGPU, sizeof(float), cudaMemcpyDeviceToHost);

  // Сравнение результатов
  cout << "CPU: " << answerCPU << " GPU: " << *answerGGPU << endl;
  if (abs(answerCPU - *answerGGPU) < 1e-4) {
      cout << "Результаты совпадают!" << endl;
  } else {
      cout << "Результаты не совпадают!" << endl;
  }

  // Освобождение ресурсов
  delete[] A;
  delete[] B;
  delete answerGPU;
  delete answerGGPU;
  cudaFree(cudaA);
  cudaFree(cudaB);
  cudaFree(answerGPU);
}

int main(){
  srand(time(0));
  for(int i = 1; i < 100; i++){
    cout << "Test " << i << ":" << endl;
    tests(1000000 + 25000 * i);
  }
}
