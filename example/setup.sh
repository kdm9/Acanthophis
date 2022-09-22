#!/bin/bash
#set -xeuo pipefail
mamba env update -f environment-setup.yml
conda activate acanthophis-example
pip install -e ../
acanthophis-init --yes
# download kraken DB
mkdir -p rawdata/kraken/viral
pushd rawdata/kraken/viral
test -f  k2_viral_20201202.tar.gz || wget -q https://genome-idx.s3.amazonaws.com/kraken/k2_viral_20201202.tar.gz
tar xvf k2_viral_20201202.tar.gz
rm -f k2_viral_20201202.tar.gz
popd
snakemake --snakefile Snakefile.generate-rawdata -j 4 --use-conda --conda-frontend mamba
