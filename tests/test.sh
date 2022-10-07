#!/bin/bash
conda activate acanthophis-example
set -xeuo pipefail
acanthophis-init --yes
rm -fr output tmp
snakemake -j 8 --use-conda --ri "${@}"
