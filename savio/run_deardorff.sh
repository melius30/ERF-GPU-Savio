#!/bin/bash
#SBATCH --job-name=ERF_Deardorff
#SBATCH --partition=savio3_gpu
#SBATCH --qos=savio_lowprio
#SBATCH --account=YOUR_SAVIO_ACCOUNT
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --gres=gpu:A40:1
# Optional: add --exclude for unavailable nodes
#SBATCH --time=00:30:00
#SBATCH --output=ERF_Deardorff_%j.out
#SBATCH --error=ERF_Deardorff_%j.err

# ============================================================
# Clean ERF environment
# ============================================================

module purge

source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate erf

module load gcc/13.2.0
module load cuda/12.6.0


# ============================================================
# ERF paths
# ============================================================

export ERF_HOME="${ERF_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
export ERF_BUILD_DIR=${ERF_HOME}/build_A40
export ERF_EXE=${ERF_BUILD_DIR}/Exec/erf_exec

export CASEDIR="${ERF_HOME}/savio"
export INPUT=${CASEDIR}/inputs_deardorff


# ============================================================
# MPI / CUDA
# ============================================================

# IMPORTANT:
# Use the same OpenMPI installation with which ERF was compiled.
export MPI_ROOT="${MPI_ROOT:-$(dirname "$(dirname "$(command -v mpicxx)")")}"

export CUDA_ROOT=$(dirname $(dirname $(which nvcc)))

export PATH=${MPI_ROOT}/bin:${PATH}

export LD_LIBRARY_PATH=${MPI_ROOT}/lib:\
${CUDA_ROOT}/lib64:\
${LD_LIBRARY_PATH}

hash -r


# ============================================================
# SLURM allocation
# ============================================================

echo "================================"
echo "SLURM allocation"
echo "================================"

echo "JOB_ID=$SLURM_JOB_ID"
echo "NODELIST=$SLURM_JOB_NODELIST"
echo "NTASKS=$SLURM_NTASKS"
echo "CUDA_VISIBLE_DEVICES=$CUDA_VISIBLE_DEVICES"


# ============================================================
# ERF environment
# ============================================================

echo "================================"
echo "ERF environment"
echo "================================"

echo "CONDA_DEFAULT_ENV=$CONDA_DEFAULT_ENV"
echo "CONDA_PREFIX=$CONDA_PREFIX"

echo ""
echo "Loaded modules:"
module list

echo ""
echo "gcc:"
which gcc
gcc --version


# ============================================================
# GPU status
# ============================================================

echo "================================"
echo "GPU status"
echo "================================"

nvidia-smi
nvidia-smi -L


# ============================================================
# MPI / CUDA environment
# ============================================================

echo "================================"
echo "MPI / CUDA environment"
echo "================================"

echo "MPI_ROOT=$MPI_ROOT"
echo "CUDA_ROOT=$CUDA_ROOT"

echo ""
echo "mpirun:"
which mpirun
mpirun --version

echo ""
echo "mpicc:"
which mpicc

echo ""
echo "mpicxx:"
which mpicxx

echo ""
echo "nvcc:"
which nvcc
nvcc --version


# ============================================================
# Case directory
# ============================================================

cd ${CASEDIR} || exit 1

echo "================================"
echo "Run information"
echo "================================"

echo "Node:"
hostname

echo ""
echo "Working directory:"
pwd

echo ""
echo "ERF executable:"
ls -lh ${ERF_EXE}

echo ""
echo "Input file:"
ls -lh ${INPUT}


# ============================================================
# ERF runtime linkage
# ============================================================

echo "================================"
echo "ERF library linkage"
echo "================================"

ldd ${ERF_EXE} | grep -E "libmpi|cuda|cudart|not found"


# ============================================================
# GPU / driver information
# ============================================================

echo "================================"
echo "GPU / DRIVER INFO"
echo "================================"

hostname
echo "CUDA_VISIBLE_DEVICES=$CUDA_VISIBLE_DEVICES"
nvidia-smi


# ============================================================
# Run ERF
# ============================================================

echo "================================"
echo "Starting ERF"
echo "${SLURM_NTASKS} MPI rank / 1 A40 GPU"
echo "================================"

mpirun -np ${SLURM_NTASKS} \
    ${ERF_EXE} \
    ${INPUT}

EXIT_CODE=$?

echo "================================"
echo "ERF finished"
echo "Exit code = ${EXIT_CODE}"
echo "================================"

exit ${EXIT_CODE}