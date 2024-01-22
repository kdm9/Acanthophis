# An example deployment of Acanthophis


This directory contains a somewhat contrived but complete example workflow
using the Acanthophis pipeline, primarily for continuous integration testing (to catch bugs early).
It consists of two stages, a first that does a
simplistic coalescent simulation of population variation, using the lambda
phage genome as an ancestral genome (see `./Snakefile.generate-rawdata`). The
second stage applies the read QC, alignment to reference, and variant calling
pipelines from Acanthophis to call variants in this simulated dataset.

To run this test pipeline, one must:

1. **Generate the test dataset: `bash setup.sh`**. Uses a population genetic simulation & then read simulation to generate a fake dataset.  
2. **Run the tests: `bash test.sh --quick`**. Deploys the Acanthophis pipeline, and runs a slightly reduced pipeline that requires only conda (every single step of the entire pipeline can be run by omitting `--quick`, but this can take some time)


To initialise your own workflow, [follow the main
documentation](../documentation.md). Briefly, run `acanthophis-init` in some
new directory. Then, collect your raw data, and create at least the required
metadata files and customise the config file to match your intended pipeline.
You can then run the pipeline using something like any other snakemake file,
for example `snakemake  -j 8 --use-conda`. Please follow [the documentation
](../documentation.md), which outlines this process in much more detail.
