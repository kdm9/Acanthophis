#!/bin/bash
#PBS -q normal
#PBS -l ncpus=2
#PBS -l walltime=48:00:00
#PBS -l mem=50G
#PBS -l storage=scratch/xe2+gdata/xe2
#PBS -l wd
#PBS -j oe
#PBS -m abe
#PBS -P xe2

set -ueo pipefail
TARGET=${TARGET:-all}
set -x

#snakemake \
#    -j 1 \
#    --use-conda \
#    --conda-frontend mamba \
#    --conda-create-envs-only 

snakemake               \
    --profile ./gadi/   \
    "$TARGET"
