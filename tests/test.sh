#!/bin/bash
set -euo pipefail

# Reinstall acanthophis from git
conda activate acanthophis-tests
python3 -m pip uninstall --yes acanthophis
python3 -m pip install -e ..

# re-init after reinstall
acanthophis-init --yes

# recreate the conda env
mamba env update -f environment.yml
conda activate acanthophis

# Clear outputs
rm -fr output tmp
mkdir -p output/ tmp/
touch output/nobackup tmp/nobackup

# If quick, overwrite config with cut-back version
if [[ "$1" == "--quick" ]]
then
    cp .config_quick.yml config.yml
    shift
fi

# Run pipeline
snakemake -j $(nproc 2>/dev/null || echo 2)  --software-deployment-method conda --ri "${@}"
