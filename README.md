# ERF-GPU-Savio

### GPU-Accelerated Atmospheric Modeling with NVIDIA CUDA, AMReX, and MPI

A GPU-enabled deployment and simulation workflow for the [Energy Research and Forecasting (ERF)](https://github.com/erf-model/ERF) model on UC Berkeley's Savio HPC cluster.

This project demonstrates CUDA-enabled compilation, MPI integration, SLURM scheduling, and successful execution of a three-dimensional Deardorff atmospheric boundary layer (ABL) simulation on an **NVIDIA A40 GPU**.

## GPU Computing Environment

| Component | Configuration |
|---|---|
| GPU | NVIDIA A40 (48 GB) |
| Architecture | NVIDIA Ampere (SM 86) |
| CUDA Toolkit | 12.6 |
| GPU Framework | AMReX |
| Compiler | GCC 13.2.0 |
| MPI | OpenMPI 4.1.6 |
| Precision | Double |
| Build | Release |
| HPC System | UC Berkeley Savio |

## Verified GPU Simulation

A three-dimensional Deardorff ABL simulation was successfully completed using the CUDA-enabled ERF executable.

| Performance Metric | Result |
|---|---|
| Simulation steps | 4,000 |
| Simulated duration | 400 seconds |
| ERF-reported total runtime | **98.13 seconds** |
| Grid cells advanced per step | 262,144 |
| Final plotfile | `plt04000` |
| Final checkpoint | `chk04000` |
| Exit code | 0 |

**Tested ERF commit:** `b338cc077`

The successful run was performed using the commit above. The current repository is based on a newer ERF development revision, which has not yet been independently validated using this workflow.

No CPU-versus-GPU speedup is claimed without a corresponding CPU benchmark.

## Simulation Visualization

![Deardorff atmospheric boundary layer simulation](savio/results/w_0300s.png)

*Visualization from the Deardorff ABL simulation.*

## Reproducible GPU Workflow

The [`savio/`](savio/) directory contains the GPU deployment workflow:

| File | Description |
|---|---|
| `build_gpu.sh` | CUDA/MPI build configuration for NVIDIA A40 |
| `run_deardorff.sh` | SLURM GPU execution script |
| `inputs_deardorff` | Deardorff ABL simulation configuration |
| `results/w_0300s.png` | Simulation visualization |
| `README.md` | Savio-specific setup and results |

### Build

```bash
bash savio/build_gpu.sh
```

### Execute

Configure the Savio account and compatible MPI environment in the submission script, then run:

```bash
sbatch savio/run_deardorff.sh
```

The portable build and execution scripts have not yet been retested against the newer ERF development revision.

## Research Direction

This work supports ongoing exploration of GPU-accelerated atmospheric simulations, with particular interest in:

- High-resolution atmospheric boundary layer modeling
- GPU-accelerated methane transport and dispersion
- Landfill emission modeling and source inversion
- CPU/GPU performance benchmarking and scalability

The landfill methane extensions are future research directions, not implemented capabilities of this repository.

## Acknowledgments

This project builds on the open-source [ERF](https://github.com/erf-model/ERF) and [AMReX](https://github.com/AMReX-Codes/amrex) software ecosystems.

The Savio deployment scripts and simulation workflow are documented independently to support reproducibility and further GPU computing research.