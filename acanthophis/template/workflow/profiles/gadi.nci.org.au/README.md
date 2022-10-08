Cluster configuration for NCI's Gadi cluster, in Canberra, Australia.

To deploy to your own project directory, please copy these three files
(`jobscrip.sh`, `cluster.yml`, `submit.sh`) to a directory named `gadi`
alongside your `Snakefile`.


# Notes

Gadi uses a heavily patched version of PBS Pro, and an environment module
system. Most nodes are 48 core, 256g ram (for queue `normal`), and all jobs
here should fit on these nodes. Each rule in `acanthophis` tries to use either
1, 2, 4, or 8 CPUs, so there shouldn't be any weird rounding error with the
number of CPUs on a box like there was with the 28 core nodes on the older
raijin.



## jobscript.sh

We use a fairly standard `jobscript.sh`, but note that one must use a
bash login shell to make conda available to the job (`#!/bin/bash -l` as the
crunchbang). If you wish to use modules, please add your `module load xxxx`
calls to the top of `jobscript.sh`. If you have installed conda to some
non-standard location, or if you have not done `conda init` to add the conda
initialisation code to your .bashrc/.profile, then you will need to add code to
enable conda to the top of `jobscript.sh` too.

That would look like:

```bash
#!/bin/bash -l

eval "$(/path/to/your/conda/install/bin/conda shell.bash hook)" 
# and/or
module load <all the software needed for the whole pipeline including snakemake and acanthophis>

# rest of the default jobscript.sh would follow
```


## cluster.yml

Here is where one can override the default resource allocations of each stage.
To do so, copy the `__default__` block, and rename it by the snakemake rule
name from acanthophis. Then edit each field accordingly to override the job
requests.


# submit.sh

This script actually submits all the jobs. It is set up as a self-submitting
PBS job itself, as snakemake will be killed after not very long on the head
node. Please edit the PBS frontmatter of submit.sh to suit your details. Please
also pay attention to -j 1000, i.e. run 1000 parallel jobs at once. This number
might need tuning, depending on how many other job-heavy workflows you or
others in your group are running at once. I think the limits are 2000 jobs per
user and 3000 jobs per project. Also note that this is the number of jobs,
*not* the number of CPUs. If each job asks for 48 cores, then 1000 = maximum
usage of 48000 cpus or about half the cluster!! Don't eat your whole allocation
at once.


## Project codes

These config files may hard-code the Borvitz lab project (`xe2`) in places.
Please check that all occurrences of xe2 are replaced with your NCI project
code if you are not part of the xe2 project.

## Conda

To use conda, install it (ideally via mambaforge, but miniconda3 also works) to
somewhere other than your home. Home directories are limited to 2GB which
aren't likely to hold a full conda install.
