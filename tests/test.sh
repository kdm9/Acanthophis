conda activate acanthophis-example
set -xeuo pipefail
acanthophis-init --yes
snakemake -j 8 --use-conda --ri
