#!/bin/bash
mamba env update -f environment-setup.yml
mamba activate acanthophis-tests
rm -rf output/ tmp/
mkdir -p output/ tmp/ rawdata/
touch output/nobackup tmp/nobackup rawdata/nobackup
python3 -m pip install -e ../
set -xeuo pipefail
snakemake --snakefile Snakefile.generate-rawdata -j 4 --software-deployment-method conda
tree rawdata
