#!/bin/bash -l 

set -ueo pipefail
TARGET="${TARGET:-all}"
set -x
mkdir -p ".snakemake/log/cluster/"

snakemake                               \
    --profile ./profiles/ebio-cluster/  \
    "$TARGET"
