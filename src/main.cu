#include <imp.cuh>
#include <iostream>
#include <ctime>

using namespace std;

void tests(int N){
  float *A = new float[N];
  float *B = new float[N];

  for (int i = 0; i < N; ++i) {
      A[i] = static_cast<float>(rand()) / RAND_MAX;
      B[i] = static_cast<float>(rand()) / RAND_MAX;
  }
  
  float answerCPU = CPUimplementation(A, B, N); // Вычисления на CPU

  float *cudaA, *cudaB, *answerGPU; // Вычисления на GPU
  cudaMalloc(&cudaA, N * sizeof(float));
  cudaMalloc(&cudaB, N * sizeof(float));
  cudaMalloc(&answerGPU, sizeof(float));

  cudaMemcpy(cudaA, A, N * sizeof(float), cudaMemcpyHostToDevice);
  cudaMemcpy(cudaB, B, N * sizeof(float), cudaMemcpyHostToDevice);

  const int block_size = 256;
  int number_of_blocks = (N + block_size - 1) / block_size;

  GPUimplementation<<<number_of_blocks, block_size>>>(cudaA, cudaB, answerGPU);
  cudaDeviceSynchronize();
  float answerGGPU;
  cudaMemcpy(&answerGGPU, answerGPU, sizeof(float), cudaMemcpyDeviceToHost);

  // Сравнение результатов
  cout << "CPU: " << answerCPU << " GPU: " << answerGGPU << endl;
  if (abs(answerCPU - answerGGPU) < 1e-5) {
      cout << "Результаты совпадают!" << endl;
  } else {
      cout << "Результаты не совпадают!" << endl;
  }

  // Освобождение ресурсов
  delete[] A;
  delete[] B;
  cudaFree(cudaA);
  cudaFree(cudaB);
  cudaFree(answerGPU);
}

int main(){
  srand(time(0));
  for(int N = 10000, i = 1; N < 250000000; N += 50000, i++){
    cout << "Test " << i << ":" << endl;
    tests(N);
  }
}
