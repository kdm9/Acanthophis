#!/bin/bash
mamba env update -f environment-setup.yml
conda activate acanthophis-tests
set -xeuo pipefail
git clean -fdx || echo "WARNING: git clean failed, beware stale files"
mkdir -p output/ tmp/ rawdata/
touch output/nobackup tmp/nobackup rawdata/nobackup
snakemake --snakefile Snakefile.generate-rawdata -j $(nproc 2>/dev/null || echo 2) --software-deployment-method conda
tree rawdata
