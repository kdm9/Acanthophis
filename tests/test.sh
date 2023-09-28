#!/bin/bash
mamba activate acanthophis-tests
set -xeuo pipefail
python3 -m pip install ..
acanthophis-init --yes
mamba env update -f environment.yml
mamba activate acanthophis
rm -fr output tmp
snakemake -j 8 --use-conda --ri "${@}"
