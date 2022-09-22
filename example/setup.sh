#!/bin/bash
#set -xeuo pipefail
mamba env update -f environment-setup.yml
conda activate acanthophis-example
pip install -e ../
acanthophis-init --yes
snakemake --snakefile Snakefile.generate-rawdata -j 4 --use-conda --conda-frontend mamba
