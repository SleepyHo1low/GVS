#include <imp.cuh>
#include <iostream>
#include <ctime>
#include <gtest/gtest.h>

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
  ASSERT_NEAR(answerCPU, answerGGPU, 1e-5) << "CPU: " << answerCPU << " GPU: " << answerGGPU;

  // Освобождение ресурсов
  delete[] A;
  delete[] B;
  cudaFree(cudaA);
  cudaFree(cudaB);
  cudaFree(answerGPU);
}

TEST(CpuGpuTests, CompareResults) {
    for (int i = 1; i <= 50; ++i) { // Запускаем 50 тестов с увеличением размера массива
        int N = 10000 + i * 50000; 
        tests(N); // Запуск теста
    }
}

int main(int argc, char **argv){
  srand(time(0));
  ::testing::InitGoogleTest(&argc, argv); 
  return RUN_ALL_TESTS();
}
