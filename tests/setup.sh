#!/bin/bash
mamba env update -f environment-setup.yml
conda activate acanthophis-tests
rm -rf output/ tmp/
pip install -e ../
set -xeuo pipefail
snakemake --snakefile Snakefile.generate-rawdata -j 4 --use-conda --conda-frontend mamba
tree rawdata
