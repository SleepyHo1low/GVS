@echo off
cd C:\Users\Professional\source\repos\GVS
mkdir build
cd build
cmake ..
cmake --build .
cd Debug
C:\Users\Professional\source\repos\zluda\zluda.exe -- gvs.exe