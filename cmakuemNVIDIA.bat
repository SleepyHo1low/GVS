@echo off
cd %~dp0
mkdir build
cd build
cmake ..	
cmake --build .
cd Debug
set CUDA_VISIBLE_DEVICES=0
gvs.exe