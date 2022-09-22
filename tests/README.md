# An example deployment of Acanthophis


This directory contains a somewhat contrived but complete example workflow
using the Acanthophis pipeline. It consists of two stages, a first that does a
simplistic coalescent simulation of population variation, using the lambda
phage genome as an ancestral genome (see `./Snakefile.generate-rawdata`). The
second stage applies the read qc, aligment to ref, and variant calling
pipelines from Acanthophis to call variants in this simulated dataset (see
`./Snakefile` and `./config.yml`). 


To run this pipeline, one must:

```bash
conda env create -f conda.yml -n acanthophis-demo
conda activate acanthophis-demo
# Install Acanthophis
pip install -e ..
# once I put this on PyPI:
# pip install acanthophis

# the generate the fake dataset
snakemake --snakefile Snakefile.generate-rawdata -j 8 --use-conda

# and run the actual test dataset
snakemake --snakefile Snakefile -j 8 --use-conda
```


To initialise your own workflow, copy `./Snakefile` and `./config.yml` to a new
directory. Establish a conda environment with some basic dependencies
(`conda create -n workflow python snakemake mamba`). Install Acanthophis (`pip
install -e $GITHUB_URL_OR_PATH_TO_CLONE_OF_ACANTOPHIS`). Then, collect your raw
data, and create at least the two metadata files (modelled after
`./data/rl2s.tsv` and `./data/samples.tsv`). Then, customise the config file
and Snakefile to match your intended pipeline. The pipeline can then be run
using something like `snakemake --snakefile Snakefile -j 8 --use-conda
--conda-frontend mamba`.

Some day soon, one will be able to do something like `acanthophis init` in some
directory for commented boilerplate to be generated in place.

A real deployment would obviously skip the creation of the fake dataset, so the
below files are of no use to you:

- `Snakefile.generate-rawdata`
- `lambda/*`
- `conda.yml`
