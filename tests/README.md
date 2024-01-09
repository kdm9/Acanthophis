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
conda env create -f environment-setup.yml -n acanthophis-demo
conda activate acanthophis-demo
# Install Acanthophis
pip install -e ..

# Initalise Acanthophis
acanthophis-init .

# the generate the fake dataset
snakemake --snakefile Snakefile.generate-rawdata -j 8 --use-conda

# and run the actual test dataset
snakemake -j 8 --use-conda
```


To initialise your own workflow, run `acanthophis-init` in some new directory.
Then, collect your raw data, and create at least the required metadata files
and customise the config file to match your intended pipeline. You can then run
the pipeline using something like any other snakemake file, for example
`snakemake  -j 8 --use-conda`. Please follow [the documentation
](../documentation.md), which outlines this process in much more detail.


A real deployment would obviously skip the creation of the fake dataset, so the
below files are of no use to you:

- `Snakefile.generate-rawdata`
- `lambda/*`
- `conda.yml`
