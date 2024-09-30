#include "imp.cuh"
#include <iostream>
#include <ctime>
#include <random>
#include <vector>

using namespace std;

void tests(int N, vector<string> &results){
  float *A = new float[N];
  float *B = new float[N];
  float *answerGPU = new float();
  float *answerGGPU = new float();
  *answerGPU = 0;
  *answerGGPU = 0;

  float mean = 0.0;      
  float stddev = 1.0;

  random_device rd;
  mt19937 gen(rd()); 
  normal_distribution<double> dist(mean, stddev);

  for (int i = 0; i < N; ++i) {
      A[i] = dist(gen);
      B[i] = dist(gen);
  }

  /*for (int i = 0; i < N; ++i) {
        A[i] = static_cast<float>(rand()) / RAND_MAX;
        B[i] = static_cast<float>(rand()) / RAND_MAX;
  }*/
  float answerCPU = CPUimplementation(A, B, N); // Вычисления на CPU

  float *cudaA, *cudaB; // Вычисления на GPU
  cudaMalloc(&cudaA, N * sizeof(float));
  cudaMalloc(&cudaB, N * sizeof(float));
  cudaMalloc(&answerGPU, sizeof(float));

  cudaMemcpy(cudaA, A, N * sizeof(float), cudaMemcpyHostToDevice);
  cudaMemcpy(cudaB, B, N * sizeof(float), cudaMemcpyHostToDevice);

  const int block_size = 256;
  int number_of_blocks = (N + block_size - 1) / block_size;

  GPUimplementation<<<number_of_blocks, block_size>>>(cudaA, cudaB, answerGPU);
  cudaDeviceSynchronize();

  cudaMemcpy(answerGGPU, answerGPU, sizeof(float), cudaMemcpyDeviceToHost);
  
  string result = "CPU: " + to_string(answerCPU) + " GPU: " + to_string(*answerGGPU);
  if (abs(answerCPU - *answerGGPU) < 1e-2) {
      result += " | Результаты совпадают!";
  } else {
      result += " | Результаты не совпадают!";
  }
  results.push_back(result);

  // Освобождение ресурсов
  delete[] A;
  delete[] B;
/*
  delete answerGPU;
  delete answerGGPU;

  cudaFree(cudaA);
  cudaFree(cudaB);
*/
  cudaFree(answerGPU);
}

int main(){
  srand(time(0));
  vector<string> result;

  for(int i = 0; i < 9; i++){
    cout << "Test " << i << ":" << "N : "  << (1 + pow(10,i)) << endl;
    tests(1 + pow(10,i), result);
  }

  cout << "\nРезультаты всех тестов:\n";
  for (const auto& res : result) {
      cout << res << endl;
  }
  
}
