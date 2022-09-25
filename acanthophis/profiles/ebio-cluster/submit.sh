#!/bin/bash -l 

set -ueo pipefail
TARGET="${TARGET:-all}"
set -x
mkdir -p "output/log/cluster/"

snakemake                               \
    --profile ./profiles/ebio-cluster/  \
    "$TARGET"
