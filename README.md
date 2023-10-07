# Acanthophis


[![DOI](https://zenodo.org/badge/345496657.svg)](https://zenodo.org/badge/latestdoi/345496657)


A reusable, comprehensive, opinionated plant hologenomics and variant calling
pipeline in Snakemake

<img src=".github/logo.jpg" width="320">

# Documentation

For documentation, see [./documentation.md](documentation.md). In summary:

```bash
# create conda env, activate it
mamba create -n someproject python snakemake pip natsort
mamba activate someproject

# Install acanthophis itself
pip install acanthophis

# Generate a workspace. This copies all files the workflow will need to your
# workspace directory.
acanthophis-init /path/to/someproject/

# Edit config.yml to suit your project. Hopefully this config file documents
# all options available in an understandable fashion. If not, please raise an
# issue on github.
vim config.yml

# Run snakemake
snakemake -j 16 -p --use-conda --conda-frontend mamba --ri

# Or on a cluster, see acanthophis-init --list-available-profiles
snakemake --profile ./ebio-cluster/
```



## About & Authors

This is an amalgamation of several pipelines developed between the [Weigel
Group, MPI DB, Tübingen, DE](https://weigelworld.org), the [Warthmann Group,
IAEA/FAO PBGL, Seibersdorf, AT](http://warthmann.com) and the [Borevitz Group,
ANU, Canberra, AU](https://borevitzlab.anu.edu.au). This amalgamation authored
by Dr. K. D. Murray, original code primary by K. D. Murray, Norman Warthmann,
with contributions from others at the aforementioned institutes.
