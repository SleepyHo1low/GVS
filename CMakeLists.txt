cmake_minimum_required(VERSION 3.24...3.30)

project(GVS_pr1 VERSION 1.0 LANGUAGES CXX CUDA)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CUDA_STANDARD 17)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -pedantic -O3")

# Добавление GoogleTest с использованием FetchContent
include(FetchContent)

FetchContent_Declare(
    googletest
    GIT_REPOSITORY https://github.com/google/googletest.git
    GIT_TAG v1.15.2
)

# Загружаем GoogleTest
FetchContent_MakeAvailable(googletest)

# Создание библиотеки imp
add_library(imp STATIC
    src/imp.cu
    src/imp.cuh
)

target_compile_features(imp PRIVATE cuda_std_17)
set_target_properties(imp PROPERTIES CUDA_ARCHITECTURE "75")

# Создание исполняемого файла gvs
add_executable(gvs src/imp.cu src/main.cu)
add_executable(gvs_tests src/imp.cu test/test.cu)


target_include_directories(gvs PUBLIC src)
target_include_directories(gvs_tests PRIVATE 
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

# Создание тестового исполняемого файла для GoogleTest
add_executable(gvs_tests test/test.cu)  # Замените на путь к вашему тестовому файлу

# Линковка с GoogleTest и вашей библиотекой imp
target_link_libraries(gvs_tests PRIVATE 
    imp 
    GTest::gtest 
    GTest::gtest_main 
)

enable_testing() # Включаем тестирование

# Регистрация тестов с помощью gtest_discover_tests
include(GoogleTest)
gtest_discover_tests(gvs_tests)
