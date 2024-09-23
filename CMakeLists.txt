cmake_minimum_required(VERSION 3.24...3.30)

project(GVS_pr1 VERSION 1.0 LANGUAGES CXX CUDA)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CUDA_STANDARD 17)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -pedantic -O3")

add_library(imp STATIC
    src/imp.cu
    src/imp.cuh
)

target_compile_features(imp PRIVATE cuda_std_17)
set_target_properties(imp PROPERTIES CUDA_ARCHITECTURE "75")

add_executable(gvs src/imp.cu src/main.cu)

target_include_directories(gvs PUBLIC src)
