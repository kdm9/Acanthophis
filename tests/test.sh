#!/bin/bash

# Reinstall acanthophis from git
conda activate acanthophis-tests
set -eo pipefail
python3 -m pip uninstall --yes acanthophis
python3 -m pip install -e ..

# re-init after reinstall
rm -rf output/ tmp/ workflow config.yml Snakefile environment.yml
mkdir -p output/ tmp/
touch output/nobackup tmp/nobackup
acanthophis-init --yes

# recreate the conda env
mamba env update -f environment.yml
conda activate acanthophis


# If quick, overwrite config with cut-back version
SDM=(conda)
if [[ "${1:-notquick}" == "--quick" ]]
then
    cp .config_quick.yml config.yml
    shift
else
    SDM+=(apptainer)
fi

# Run pipeline
snakemake -j $(nproc 2>/dev/null || echo 2)  --software-deployment-method "${SDM[@]}" --ri "${@}"
