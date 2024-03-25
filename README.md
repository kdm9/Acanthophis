# Acanthophis


[![DOI](https://joss.theoj.org/papers/10.21105/joss.06062/status.svg)](https://doi.org/10.21105/joss.06062)

A reusable, comprehensive, opinionated Snakemake pipeline for plant-microbe genomics and plant variant calling.

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

### Compatibility

While snakemake and Acanthophis are cross-platform, most of the underlying tools are only packaged for and/or only operate on  Linux `x68_64`. Therefore, I only support users on Linux systems. In theory, everything *should* run on OSX or WSL, but the vast majority of users will want to utilise a high performance linux workstation (at least, probably more likely a cluster).

### Running tests

For running tests, see [./tests/README.md](tests/README.md).

# Contribution & Assistance

If you have anything (advice, docs, code) you'd like to contribute, pull requests are more than welcome. Please discuss any major contribution in a new issue before implementing it, to avoid wasted effort.

If you need any assistance, or have other questions or comments, please make an issue on github, or open a discussion. Unfortunately both need an account on github, so alternatively you can email me (`foss  <usual email symbol> kdmurray.id.au`).

## About & Authors

This is an amalgamation of several pipelines developed between the [Weigel
Group, MPI DB, Tübingen, DE](https://weigelworld.org), the [Warthmann Group,
IAEA/FAO PBGL, Seibersdorf, AT](http://warthmann.com) and the [Borevitz Group,
ANU, Canberra, AU](https://borevitzlab.anu.edu.au). This amalgamation authored
by Dr. K. D. Murray, original code primary by K. D. Murray, Norman Warthmann,
with contributions from others at the aforementioned institutes.
