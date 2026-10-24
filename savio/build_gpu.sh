#!/bin/bash
set -euo pipefail

module purge
module load gcc/13.2.0
module load cuda/12.6.0

# Ensure the same OpenMPI toolchain is available.
command -v mpicxx
command -v nvcc

ERF_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ERF_HOME"

cmake -S . -B build_A40 \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_COMPILER="$(command -v mpicxx)" \
    -DCMAKE_CUDA_ARCHITECTURES=86 \
    -DERF_ENABLE_CUDA=ON \
    -DERF_ENABLE_MPI=ON \
    -DAMReX_GPU_BACKEND=CUDA \
    -DAMReX_CUDA_FASTMATH=ON \
    -DAMReX_GPU_MAX_THREADS=256 \
    -DAMReX_PRECISION=DOUBLE \
    -DERF_ENABLE_NETCDF=OFF

cmake --build build_A40 --parallel 8
