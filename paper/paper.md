---
title: 'Acanthophis: a comprehensive plant hologenomics pipeline'
tags:
  - python
  - snakemake 
  - plants
  - metagenomics
  - variant calling
  - population genomics
authors:
  - name: Kevin D. Murray
    orcid: 0000-0000-0000-0000
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
    affiliation: 3
    corresponding: true
affiliations:
 - name: Max Planck Institute for Biology, Tübingen, Deutschland
   index: 1
 - name: Research School of Biology, Australian National University, Canberra, Australia
   index: 2
 - name: IAEA/FAO Molecular Plant Genetics and Breeding Lab, Siebersdorf, Austria
   index: 3
date: 10 October 2023
bibliography: paper.bib
---

# Summary


Acanthophis is a comprehensive pipeline for the joint analysis of both plant genetic variation and variation in the composition and abundance of plant-associated microbiomes.
Implemented in Snakemake[@koster12_snakemakescalable], Acanthophis handles reads from raw FASTQ files through quality control, alignment of reads to a plant reference, variant calling, taxonomic classification and quantification, and metagenome analysis.
The workflow contains numerous practical optimisations, both to reduce disk space usage and maximise utilisation of computational resources. 
Acanthophis is available under the Mozilla Public Licence v2 at <https://github.com/kdm9/Acanthophis> and as a python package installable from PyPI (`pip install acanthophis`).

# Statement of Need

Modern plant-pathogen interaction genomics relies on the joint characterisation of the genomes of both plant hosts and their associated microbes.
Such analyses are often incredibly data intensive, particularly at the scale required for quantitative analyses, which often incorporate thousands of host individuals[@weigel20_pathocomproposal].
These analyses demand computationally-efficient pipelines that perform both host genotyping and host-associated microbiome characterisation in a consistent, flexible, and reproducible fashion.

We developed Acanthophis out of a lack of such pipelines, with most previous pipelines performing only a subset of these tasks (e.g. Snakemake's variant calling pipeline [@koster21_snakemakeworkflows]). In addition, most host-aware microbiome analysis pipelines do not allow for host genotyping and/or assume an animal host (e.g. Taxprofiler[@yates23_nfcore]). Acanthophis has attracted many of users, including published papers and preprints (e.g. @murray19_landscape; @ahrens21_genomic).

# Components and Features

Across the entire pipeline, we operate on sample sets. Each sample set consists of one or more samples, and each sample can be in any number of sample sets. For each sample set, we can configure which analyses to run (most can be disabled if not needed), and we can also configure tool-specific or general settings or thresholds. This configuration happens via a global `config.yaml` file, of which we provide an exhaustively documented template.

## Stage 1: Raw reads to per-sample reads

Input data consists of a FASTQ file (or pair thereof) per **run** of each **library** corresponding to one **sample**. For each **run-lib** (one run of one library), we use `AdapterRemoval` [@schubert16_adapterremoval] to remove low quality or adaptor sequences, and to merge overlapping read pairs. We use `FastQC` to summarise sequence quality before and after `AdaptorRemoval`. Reads can then be optionally merged to one file per sample.

## Stage 2: Alignment to reference(s)

We use either `BWA MEM`[@li13_aligningsequence], `NGM`[@sedlazeck13_nextgenmapfast], or `minimap2`[@li18_minimap2pairwise;@li21_newstrategies] to align reads to each reference genome. Quality-controlled per-run and -library FASTQ files are aligned with the configured aligners. We then merge per-runlib BAMs to per-sample BAMs, and then use `samtools markdup`[@li09_sequencealignment;@danecek21_twelveyears] to mark duplicated reads. Input reference genomes should be uncompressed, `samtools faidx`ed FASTA files. 

## Stage 3: Variant Calling

We use either `bcftools mpileup` or `freebayes` to call raw variants, using priors and thresholds configured for each sample set. We then normalise variants with `bcftools norm`, and then split multiallelic variants, filter each allele with per-sample set filters, and combine filter-passing alleles back into unique sites. Resulting variants are then indexed, and statistics calculated. To parallelize variant calling, we use one of two approaches: either a static list of non-overlapping genome windows is used (as supplied in a BED file), or a total coverage is used to break the genome into buckets with approximately equal amounts of data.

## Stage 4: Taxon profiling
We use any of Kraken 2 (with or without Bracken [@lu17_brackenestimating]), Kaiju[@menzel16_fastsensitive], Centrifuge[@kim16_centrifugerapid], and Diamond[@buchfink15_fastsensitive] to create taxonomic profiles for each sample against any number of supplied databases. We then use taxpasta[@beber23_taxpastataxonomic] to combine multiple profiles into tables for easy downstream use.

## Stage 5: Reporting and Statistics

Throughout all pipeline stages, various tools output summaries of their actions and/or outputs. We optionally combine these into unified reports by pipeline stage and sample set using MultiQC[@ewels16_multiqcsummarize].

# Acknowledgements

We thank Luisa Teasdale, Anne-Cecile Colin, Rose Andrew, Johannes Köster, and Scott Ferguson for comments or advice on Acanthophis and/or on this manuscript. KDM is supported by a Marie Skłodowska-Curie Actions fellowship.

# References
