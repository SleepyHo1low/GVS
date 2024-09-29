cmake_minimum_required(VERSION 3.24...3.30)

project(GVS_pr1 VERSION 1.0 LANGUAGES CXX CUDA)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CUDA_STANDARD 17)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -pedantic -O3")

# Добавление GoogleTest
include(FetchContent)

FetchContent_Declare(
    googletest
    GIT_REPOSITORY https://github.com/google/googletest.git
    GIT_TAG        release-1.11.0  # Укажите версию, которую хотите использовать
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

target_include_directories(gvs PUBLIC src)

# Добавление тестов
enable_testing()

# Создание тестового исполняемого файла
add_executable(gvs_tests test/test.cu)  # Замените на путь к вашему тестовому файлу

# Линкование с GoogleTest и вашей библиотекой imp
target_link_libraries(gvs_tests PRIVATE GTest::gtest GTest::gtest_main imp)

# Регистрация тестов
include(GoogleTest)
gtest_discover_tests(gvs_tests)
