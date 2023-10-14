---
title: 'Acanthophis: a comprehensive plant hologenomics pipeline'
tags:
  - python
  - snakemake 
  - plants
  - metagenomics
  - variant calling
  - population genomics
  - reference-free classification
authors:
  - name: Kevin D. Murray
    orcid: 0000-0002-2466-1917
    email: kdmpapers@gmail.com
    affiliation: 1
    corresponding: true
  - name: Justin O. Borevitz
    orcid: 0000-0001-8408-3699
    affiliation: 2
  - name: Detlef Weigel
    orcid: 0000-0002-2114-7963
    affiliation: 1
  - name: Norman Warthmann
    orcid: 0000-0002-1178-8409
    affiliation: 2,3
    corresponding: true
affiliations:
 - name: Max Planck Institute for Biology, Tübingen, Deutschland
   index: 1
 - name: Research School of Biology, Australian National University, Canberra, Australia
   index: 2
 - name: FAO/IAEA Joint Centre of Nuclear Techniques in Food and Agriculture, Plant Breeding and Genetics Laboratory, Seibersdorf, Austria
   index: 3
date: 10 October 2023
bibliography: paper.bib
---

# Summary


Acanthophis is a comprehensive pipeline for the joint discovery and analysis of both plant genetic variation and variation in the composition and abundance of plant-associated microbiomes.
Implemented in Snakemake [@koster12_snakemakescalable], Acanthophis handles data from raw FASTQ read files through quality control, alignment of the reads to a plant reference, variant calling, taxonomic classification and quantification of microbes, and metagenome analysis.
The workflow contains numerous practical optimisations, both to reduce disk space usage and maximise utilisation of computational resources. 
Acanthophis is available under the Mozilla Public Licence v2 at <https://github.com/kdm9/Acanthophis> as a python package installable from conda or PyPI (`pip install acanthophis`).

# Statement of Need

Understanding plant biology benefits from ecosystem-scale analysis of genetic variation, and increasingly demands the characterisation of not only plant genomes but also the genomes of their associated microbes.
Such analyses are often data intensive, particularly at the scale required for quantitative analyses, i.e. thousands of host individuals [@regalado20_combining; @karasov22_drought].
They demand computationally-efficient pipelines that perform both host genotyping and host-associated microbiome characterisation in a consistent, flexible, and reproducible fashion.

Currently, no such unified pipelines exist. Previous pipelines perform only a subset of these tasks (e.g. Snakemake's variant calling pipeline; @koster21_snakemakeworkflows). In addition, most host-aware microbiome analysis pipelines do not allow for host genotyping and/or assume an animal host (e.g. Taxprofiler; @yates23_nfcore). Acanthophis has attracted many users, and has been referred to in peer-reviewed journal articles and preprints (e.g. @murray19_landscapedrivers; @ahrens21_genomicconstraints).

# Components and Features

Acanthophis is a pipeline for the analysis of plant population resequencing pipeline. It expect short-read shotgun whole (meta-)genome sequencing data, typically of plants collected in the field. A typical dataset might be 10s-1000s of samples from one or multiple closely related species, sequenced with 2x150bp paired-end short read sequencing. In a plant-microbe interaction genomics study, these plants and therefore sequencing libraries can contain microbes (a "hologenome"), however datasets focusing only on host genome variation are also catered for. Acanthophis can be configured to do any of the following analyses: mapping reads to a reference, calling variants, annotating variant effects, estimating genetic distances *de novo*, and profiling and/or assembling metagenomes. While we developed Acanthophis to handle plant data, there is no reason why it cannot be applied to other taxa, however some parameters may need adjustment.

Across the entire pipeline, we operate on 'sample sets', named groups of one or more samples; each sample can be in any number of sample sets. For each sample set, we can configure the analyses to run (most can be disabled if not needed). We can also configure tool-specific settings or thresholds. The pipeline is  configured via a global `config.yaml` file. We provide a documented template.

## Stage 1: Raw reads to per-sample reads

Input data consists FASTQ files per **run** of each **library** corresponding to a **sample**. For each **run-lib** (one run of one library), we use `AdapterRemoval` [@schubert16_adapterremoval] to remove low quality or adaptor sequences, and to merge overlapping read pairs. We use `FastQC` to summarise sequence QC before and after `AdaptorRemoval`. 

## Stage 2: Alignment to reference(s)

For read alignment to reference genomes we provide several configurable aligners, currently `BWA MEM` [@li13_aligningsequence], `NGM` [@sedlazeck13_nextgenmapfast], and `minimap2` [@li18_minimap2pairwise;@li21_newstrategies]. We then merge per-runlib BAMs to per-sample BAMs, and use `samtools markdup` [@li09_sequencealignment;@danecek21_twelveyears] to mark duplicate reads. Input reference genomes should be uncompressed, `samtools faidx`ed FASTA files. 

## Stage 3: Variant Calling

We provide `bcftools mpileup` or `freebayes` to call raw variants, using priors and thresholds configurable for each sample set. We then normalise variants with `bcftools norm`, split multiallelic variants, filter each allele with per-sample set filters, and combine filter-passing alleles back into unique sites. Resulting variants are indexed and statistics calculated (bcftools stats). To parallelize variant calling: either a static list of non-overlapping genome windows is used (as supplied in a BED file), or mosdepth is used to break the genome into buckets with approximately equal amounts of data.

## Stage 4: Taxon profiling

We use any of Kraken 2 [@wood19_improved], Bracken [@lu17_brackenestimating], Kaiju [@menzel16_fastsensitive], Centrifuge [@kim16_centrifugerapid], and Diamond [@buchfink15_fastsensitive] to create taxonomic profiles for each sample against any number of supplied databases. We then use taxpasta [@beber23_taxpastataxonomic] to combine multiple profiles into tables for easy downstream use.

## Stage 5: *De novo* Estimates of Genetic Dissimilarity

Acanthophis can use either `kWIP` [@murray17_kwipkmer] or Mash [@ondov16_mashfast] to estimate genetic distances between samples without alignment to a reference genome. These features first sketch reads into kmer sketches, and then calculate pairwise distances among samples.

## Stage 5: Reporting and Statistics

Throughout all pipeline stages, various tools output summaries of their actions and/or outputs. We optionally combine these into unified reports by pipeline stage and sample set using MultiQC [@ewels16_multiqcsummarize].

# Acknowledgements

We thank Luisa Teasdale, Anne-Cecile Colin, Rose Andrew, Johannes Köster, and Scott Ferguson for comments or advice on Acanthophis and/or on this manuscript. KDM is supported by a Marie Skłodowska-Curie Actions fellowship.

# References
