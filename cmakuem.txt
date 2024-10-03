@echo off
cd C:\Users\Professional\source\repos\GVS
mkdir build
cd build
cmake ..
cmake --build .
cd Debug
set CUDA_VISIBLE_DEVICES=1
C:\Users\Professional\source\repos\zluda\zluda.exe -- gvs.exe