#!/bin/bash
set -euo pipefail
mamba activate acanthophis-tests
python3 -m pip uninstall --yes acanthophis
python3 -m pip install -e ..
acanthophis-init --yes
mamba env update -f environment.yml
mamba activate acanthophis
set -x
snakemake -j $(nproc 2>/dev/null || echo 2)  --software-deployment-method conda apptainer --ri "${@}"
