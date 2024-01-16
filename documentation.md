# Acanthophis Tutorial

![](.github/logo.jpg)


Acanthophis is a flexible and performant analysis pipeline for short read resequencing data. At its core, Acanthophis is a reference-based mapping and variant calling pipeline, with optional modules for hologenomics (the combined analysis of genomes from some host and its microbial pathogens or symbionts), *de novo* distance estimation, and various further analyses of population resequencing data.

Acanthophis aims for maximal flexibility and performance, and therefore presents the user with an at first dazzling number of knobs to twiddle. The aim of this tutorial is to show you what the various moving pieces of Acanthophis do, how they interact, and how they are configured.

# tl;dr:

```bash
# create conda env, activate it
mamba create -n someproject python snakemake=8 pip natsort
mamba activate someproject

# Install acanthophis itself
python3 -m pip install acanthophis

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


## Recap: Snakemake basics

[Snakemake](https://snakemake.rtfd.io) is a python-based workflow manager. Stripped of all its fanciness, Snakemake is just a tool that writes and runs shell scripts for you. However, Snakemake automatically handles a huge number of the more annoying parts of writing and executing those shell scripts yourself, for example parallelism, cluster interaction, software installation, and clean and reproducible restart behaviour.

Instead of rewriting the Snakemake documentation here, I'll point you at the excellent tutorials and reference manual on the [Snakemake docs website](https://snakemake.rtfd.io). As a very brief reminder though, in Snakemake, each job is described as a generic rule, for example mapping some reads:

```
rule bwamem:
    input:
        reads="input/reads/{sample}.fastq.gz",
        reference="input/{reference}.fa",
    output:
        bam="tmp/bams/{reference}/{sample}.bam",
        bai="tmp/bams/{reference}/{sample}.bam.bai"
    shell:
        "(bwa mem"
        "    {input.reference}"
        "    {input.reads}"
        " | samtools view -Su"
        " | samtools sort -o {output.bam}"
        " && samtools index {output.bam})"
```

In the above you see the three main blocks of a Snakemake rule: a generic list of inputs, a generic list of outputs, and a generic shell command (including pipes, `&&`, and other shell features).

Note that we never actually tell Snakemake directly which reference or sample to run, instead using [wildcards](https://snakemake.readthedocs.io/en/stable/tutorial/basics.html#step-2-generalizing-the-read-mapping-rule) that denote how **in general** *any* given sample should be mapped to *any* given reference.

Obviously the above is insufficient for anything to actually run: we need to add some targets and/or configuration that describes (for our toy example) which samples should be mapped to which references.

```
rule all:
   input:
      [f"tmp/bams/{reference}/{sample}.bam"
        for sample, samprefs in config["samples"].items()
        for reference in samprefs]

# Our rule from above & any others follow
rule bwamem:
....
```

Now we have a special "target" rule (traditionally named all, but it just has to be the first rule in the file) which has as `input:` everything you'd like Snakemake to make for you. Above, we look up our list of samples and references from the configuration, and use a python [list comprehension](https://www.w3schools.com/python/python_lists_comprehension.asp) to create a list of BAM files of sample X mapped to reference Y, for each X and Y in the configuration.

But, we are still missing the configuration!! For simplicity's sake, let's just manually make dictionary mapping each sample to a list of references it should be aligned to (sample 1 to refA + refB, sample 2 just to refB). Typically though, this would be in a separate file, as we will see later.

```
config["samples"] = {
    "sample1": ["refA", "refB"],
    "sample2": ["refB", ]
}

rule all:
   input:
      [f"tmp/bams/{reference}/{sample}.bam"
        for sample, samprefs in config["samples"].items()
        for reference in samprefs]

rule bwamem:
    input:
        reads="input/reads/{sample}.fastq.gz",
        reference="input/{reference}.fa",
    output:
        bam="tmp/bams/{reference}/{sample}.bam",
        bai="tmp/bams/{reference}/{sample}.bam.bai"
    shell:
        "(bwa mem"
        "    {input.reference}"
        "    {input.reads}"
        " | samtools view -Su"
        " | samtools sort -o {output.bam}"
        " && samtools index {output.bam}"
```

Now, we have a complete workflow (minus software and input data of course), and you should have all the key pieces of theory you need to understand how Acanthophis works.

# Acanthophis setup

Acanthophis is distributed as a python package. I recommend installing it using pip:

```bash
python3 -m pip install acanthophis 'snakemake[all]' natsort
```

This should have also installed Snakemake along with the many dependencies of Snakemake.

We should now have an `acanthophis-init` command:

```
acanthophis-init --help
```

We can set up an Acanthophis workspace in a new directory like this (obviously give it a more appropriate name than `my-resequencing-project`)

```
acanthophis-init my-resequencing-project
cd my-resequencing-project
```

If we look what was made, we should see the following files (I've annotated what each is/does with comments)

```
$ tree
.
├── config.yml                        # The main configuration file
├── profiles                          # Cluster execution profiles, if any
├── environment.yml                   # A global conda environment
├── rawdata                           # A directory to store raw input data
│   ├── runlib2samp.tsv               # An example manifest file (see below)
│   └── adapters.txt                  # An example adaptor sequence file
└── workflow                          # The core Acanthophis workflow code
    ├── config.schema.yml
    ├── rules                         # Snakemake rule files
    │   ├── align.rules                 
    │   ├── base.rules
    │   ├── denovo.rules
    │   ├── metagenome.rules
    │   ├── reads.rules
    │   ├── sampleset.rules
    │   ├── taxonid.rules
    │   ├── varcall.rules
    │   ├── variantannotation.rules
    │   └── envs                      # Conda environment files for each rule
    │       ├── align.yml
    │       ├── bakery.yml
    │       ├── centrifuge.yml
    │       ├── diamond.yml
    │       ├── global.yml
    │       ├── idxcov.yml
    │       ├── kaiju.yml
    │       ├── kraken.yml
    │       ├── kwip.yml
    │       ├── mash.yml
    │       ├── megahit.yml
    │       ├── qcstats.yml
    │       ├── qualimap.yml
    │       ├── reads.yml
    │       ├── snpeff.yml
    │       ├── sra.yml
    │       └── varcall.yml
    └── Snakefile                     # The global snakemake "target" file
```

There are a couple of key files that we will need to configure: `config.yml`, `rawdata/runlib2samp.tsv`,  and any cluster profile we need to execute the workflow[^1]. 

[^1]: For users at one of the institutes I have worked at (ANU, MPI Tübingen), I provide a cluster profile for the systems we have access to [here](https://github.com/kdm9/Acanthophis/tree/main/acanthophis/template/workflow/profiles). For others, you can adapt these to your cluster, especially when combined with [the upstream snakemake profile collection](https://github.com/snakemake-profiles).

Everything under `workflow/` should be more or less static. You can of course customise the workflow for your needs, but if you want to run a fairly standard variant calling pipeline, then you should not need to.


# Configuring Acanthophis

Acanthophis is configured primarily by editing the `config.yml` file. The example file is self-documenting. For completeness, I copy the entire documented contents below (but use the automatically-generated one as your template, as the below may drift out of sync with the current state of the code if I forget to update it -- file an issue if so).

```
#######################################################################
#                             Data Paths                              #
#######################################################################
data_paths:
  # Metadata locations.
  metadata:
    # This file maps the FASTQ files associated with a run of a library to a
    # samplename, and to any other relevant metadata.
    runlib2samp_file: "rawdata/rl2s.tsv"
    # This is a shell glob pattern defining the text files containing lists of
    # samplenames per sample set.
    setfile_glob: "rawdata/samplesets/*.txt"

  # Reference Genomes
  references:
    lambda:
      fasta: "rawdata/reference/genome.fa"

  # Taxon profiling databases
  kraken:
    Viral:
      dir: "rawdata/kraken/Viral"
      # If the database contains Bracken dbs, please uncomment the below and
      # specify the bracken db sequence/kmer length to use
      #bracken: 150
  kaiju:
    Viral:
      nodes: "rawdata/kaiju/Viral/nodes.dmp"
      fmi: "rawdata/kaiju/Viral/kaiju_db_viruses.fmi"
  centrifuge:
    lambda: "rawdata/centrifuge/lambda/lambda.1.cf"
  # This directory should contain nodes.dmp and names.dmp from NCBI's taxdump.tar.gz
  ncbi_taxonomy: "rawdata/ncbitax/"

  # These are prefixes for output files, either temporary or persistent.
  temp_prefix: "tmp/"
  persistent_prefix: "output/"

#######################################################################
#                      Sample Set Configuration                       #
#######################################################################
#
# This section is where we tell snakemake which files to generate for each set
# of samples. Samplesets are configured as files of sample names (see
# setfile_glob above). 

samplesets:

  # `all_samples` is a inbuilt sample set, corresponding to all samples in the
  # runlib2samp_file from above. If you only have one logical set of samples, you can use
  # this as the sampleset name. If you have multiple sample sets, please
  # duplicate this entire section for each sample set, and modify the settings
  # accordingly.
  all_samples:
    
    # Alignment of reads to a reference
    align:
      
      # Which aligners should be used to map reads?
      aligners:
        - bwa
        - ngm
      
      # Against which references should we align?
      references:
        # Remember, each reference here must be defined in
        # data_paths/references above.
        - lambda

      # Should we extract unmapped reads from each BAM?
      unmapped_reads: true
      # Should BAMs be kept longer than needed?
      keep_bams: false 
      # Generate samtools statistics?
      stats: true
      # Use qualimap to generate additional statistics?
      qualimap: true

    # Taxonomic classification
    kraken:
      dbs:
        # Remember, each database here must be defined in data_paths/kraken
        # above.
        - Viral
      # Output (un)-classified read fastqs from Kraken?
      reads: false
    kaiju:
      dbs:
        # Remember, each database here must be defined in data_paths/kaiju
        # above.
        - Viral
    centrifuge:
      dbs: []
        # Centrifuge is disabled in this example as we use this in CI testing
        # and centrifuge uses too much RAM, causing our tests to fail. To run
        # centrifuge, supply an array/list of databases here as one does above
        # for Kraken & Kaiju, for exampe:
        #
        # - lambda
    
    # Make a sample_R1/R2.fastq.gz file per sample?
    persample_reads: false

    # Run FastQC per input run/library?
    fastqc: true

    # Calculate distances with Mash/KWIP?
    mash: true
    kwip: true

    # Variant calling
    varcall:
      # Which variant callers to use?
      callers:
        - mpileup
        - freebayes
      # Which short read aligners to use for variant calling? (can be
      # more/less/different to the align section above)
      aligners:
        - bwa
      # Which references to use for variant calling? (again can be
      # more/less/different to the references used for read alignment based
      # analyses above).
      refs:
        - lambda

      # Which set of filter expressions to use? (see tool_settings section below)
      filters:
        - default

      # Depth per sample before we either discard a site or thin reads. Set
      # this conservatively high, as the behaviour is different between variant
      # callers: Freebayes skips sites with more than this many reads per
      # sample on average, whereas mpileup subsamples to this many reads.
      max_depth_per_sample: 400

      # Only genotype the N best alleles. A considerable performance tunable,
      # especially for freebayes.
      best_n_alleles: 4

      # At least 4 reads in at least one sample to call it a variant
      min_alt_count: 4

      # Organism's ploidy?
      ploidy: 2

      # Prior on the proportion of variable sites (Θ)
      theta_prior: 0.01

      # Use SNPEff to annotate variant effects? Requires a rather specific set
      # of precomputed references, refer to the SNPeff docs. Personally I've
      # had better luck with bcftools csq, which will be supported here soon.
      snpeff: false


tool_settings:
  # Compression level. This sets a trade-off between compression time and disk
  # usage. If disk is limiting, increase, if CPUS expensive, decrease. Default
  # should be 6.
  ziplevel: 6

  samtools:
    # Sort memory per thread
    sortmem_mb: 100

  ngm:
    # Alignment speed-sensitivity tradeoff, see NGM docs:
    # https://github.com/Cibiv/NextGenMap/wiki/Documentation#general
    sensitivity: 0.5

  adapterremoval:
    # This mapping is keyed by the qc_type column of the provided metadata,
    # allowing for differing QC settings per input. If no such column is found,
    # then we use the __default__ value as below.
    
    # global defaults.
    __default__:
      adapter_file: "rawdata/adapters.txt"
      minqual: 20
      qualenc: 33
      maxqualval: 45

  # Kwip and Mash settings, constant for all samplesets (TODO: move to per sampleset)
  kwip:
    kmer_size: 21
    sketch_size: 300000000
  mash:
    kmer_size: 21
    sketch_size: 100000

  varcall:
    # Per-aligner minimum MAPQ thresholds for using a read.
    minmapq:
      # bwa scores approximately follow a PHRED scale (-10*log10(p))
      bwa: 30
      # NGM scores are bonkers, and don't follow a particularly clear scale. In
      # practice ~10 seems appropriate
      ngm: 10

    # Minimum base quality to count *base* in pileup
    minbq: 15 
    
    # Coverage per region across all samples. This is used to partition the
    # genome in a coverage-aware manner with goleft indexcov.
    # The values below are stupidly low for testing purposes, you should
    # increase the to at least the numbers in the comments.
    region_coverage_threshold:
      mpileup:    5  # 10000
      freebayes:  5  #  1000

    # Filters. These are series of command line arguments to pass to bcftools
    # view. These filters apply while multiallelic variants have been
    # decomposed into multiple overlapping variant calls. This allows e.g.
    # allele frequency filters to be performed on a per-allele basis. Please
    # only very lighly filter variants, as variant filtering is a highly task-
    # and question-specific decision, and these variant files should be good
    # for use in any downstream application.
    filters:
      default: >
        -i 'QUAL >= 10 &&
            INFO/DP >= 5 &&
            INFO/AN >= 3'

  # To avoid errors with overly long command lines, or "too many open files",
  # we merge region bcfs in two rounds, first to per-group bcfs with each group
  # containing this number of regions, then we merge the groups to the final
  # global bcf.
  bcf_merge_groupsize: 900

#######################################################################
#                           Resource Config                           #
#######################################################################
resources:
  # set to true to see all the resources for each rule
  __DEBUG__: false
  __default__:
    # A default set of resources. Jobs not configured individually will inherit these values.
    cores: 1
    disk_mb: 32000
    mem_mb: 1000
    time_min: 120
    localrule: 0  # this must be an integer, so 0 = false & 1 = true
  __max__:
    # A maximum of each resource permitted by your execution environment. Each job's
    # request will be capped at these values.
    # 
    # On cloud environments, use the maximum available resources of your machine type. On
    # HPC clusters, use the size of an individual node. On a local machine, use the size
    # of the machine you run snakemake on.
    cores: 32
    disk_mb: 300000
    mem_mb:  120000
    time_min: 2880
  # What follows overrides both the defaults above and any per-job specification in the 
  # snakemake rules files. The keys of this should be individual rule names as passed to
  # configure_resources() in the snakemake rules files. Run snakemake -np with the
  # __DEBUG__ variable above set to true to see a full list of the defaults.
  example_rule_name:
    cores: 8
    disk_mb: 300000
    mem_mb: 16000
    time_min: 120
```

### Manifest file: `runlib2sample.tsv`

Another critical user-facing configuration file is the manifest, or `runlib2sample` file. This is a csv or tsv table that maps the location of FASTQ files per run and library to a sample, along with other data. An example is copied below.

|run |library|sample|include|read1_uri                          |read2_uri                          |interleaved_uri|single_uri|qc_type|
|:---|:------|:-----|:------|:----------------------------------|:----------------------------------|:--------------|:---------|:------|
|Run1|S01a   |S01   |Y      |rawdata/reads/Run1/S01a_R1.fastq.gz|rawdata/reads/Run1/S01a_R2.fastq.gz|               |          |nextera|
|Run2|S01a   |S01   |Y      |rawdata/reads/Run2/S01a_R1.fastq.gz|rawdata/reads/Run2/S01a_R2.fastq.gz|               |          |nextera|
|Run1|S01b   |S01   |Y      |rawdata/reads/Run1/S01b_R1.fastq.gz|rawdata/reads/Run1/S01b_R2.fastq.gz|               |          |nextera|
|Run2|S01b   |S01   |Y      |rawdata/reads/Run2/S01b_R1.fastq.gz|rawdata/reads/Run2/S01b_R2.fastq.gz|               |          |nextera|
|Run1|S02a   |S02   |Y      |rawdata/reads/Run1/S02a_R1.fastq.gz|rawdata/reads/Run1/S02a_R2.fastq.gz|               |          |nextera|
|Run2|S02a   |S02   |Y      |rawdata/reads/Run2/S02a_R1.fastq.gz|rawdata/reads/Run2/S02a_R2.fastq.gz|               |          |nextera|
|Run1|S02b   |S02   |Y      |rawdata/reads/Run1/S02b_R1.fastq.gz|rawdata/reads/Run1/S02b_R2.fastq.gz|               |          |nextera|

These columns denote:

- `run`: A name for the sequencing run. No two independent runs can have the same name, and you can't have a library occur more than once in a run. Can use any valid path characters except `~`.
- `library`: A name for this sequencing library. No two independent libraries should have the same name, even if they are from the same sample.
- `sample`: A name for the biological sample that a library is derived from.
- `include`: A boolean `Y/N` column indicating which samples to include. Can be used to exclude failed runs or other weirdness.
- `read1_uri`, `read2_uri`, `interleaved_uri`, `single_uri`. URIs to FASTQ files. Can be either an absolute or relative path in the case of local files, or any URL scheme supported by [snakemake's remote file module](https://snakemake.readthedocs.io/en/stable/snakefiles/remote_files.html). One should give either R1+R2, interleaved, or single reads. Combining interleaved and R1+R2 is impossible, and combining either with single end reads may have unexpected consequences and should be avoided -- input data should be raw, so this is a rare case.
- `qc_type` (**optional**): If your datasets contains multiple QC types (see `tool_settings/adapterremoval` in the config file), one can use this column to indicate which QC settings should be used on each runlib. Useful if e.g. you have two different adaptor preparation methods for two libraries of the same sample, and therefore two sets of adaptor sequences. If you have uniform settings this column can be left blank or removed entirely.

Importantly, any number of additional columns can appear in this file, so you can use this to store additional metadata needed for downstream analyses in one place.



# Running Snakemake

Once you have configured Acanthophis, it can be run just like any other
Snakemake workflow.

Personally, I prefer to always enable the following options (and they are
enabled in my bundled profiles):

```
snakemake \
    --rerun-incomplete \
    --keep-going \
    --use-conda \
    --conda-frontend mamba
```

One can adjust the number of local cores or cluster jobs used with the `-j` flag.

## Resource usage

Each job within Acanthophis is preconfigured with a mostly-portable estimation
of the resources it should use with most datasets. These can be overridden in
the config file. The best way to do this is to see one of the preconfigured
profiles mentioned above, and adjust it to your needs. Note that this is only
really required for cluster or cloud execution, and the defaults have been set
conservatively high so this will very rarely be needed.
