#!/bin/bash -l 

set -ueo pipefail
TARGET=${TARGET:-all}
set -x

snakemake \
    -j 1 \
    --use-conda \
    --conda-frontend mamba \
    --conda-create-envs-only 

snakemake               \
    --profile ./ebio-cluster/   \
    "$TARGET"
