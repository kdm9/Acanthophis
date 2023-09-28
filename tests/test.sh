#!/bin/bash
conda activate acanthophis-tests
set -xeuo pipefail
python3 -m pip install ..
acanthophis-init --yes
mamba env update -f environment.yml
conda activate acanthophis
rm -fr output tmp
snakemake -j 8 --use-conda --ri "${@}"
