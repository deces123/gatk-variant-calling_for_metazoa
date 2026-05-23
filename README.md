# Snakemake workflow: dna-seq-gatk-variant-calling

[![DOI](https://zenodo.org/badge/139045164.svg)](https://zenodo.org/badge/latestdoi/139045164)
[![Snakemake](https://img.shields.io/badge/snakemake-≥6.1.0-brightgreen.svg)](https://snakemake.github.io)
[![GitHub actions status](https://github.com/snakemake-workflows/dna-seq-gatk-variant-calling/workflows/Tests/badge.svg?branch=main)](https://github.com/snakemake-workflows/dna-seq-gatk-variant-calling/actions?query=branch%3Amain+workflow%3ATests)

This is a modified version from https://github.com/snakemake-workflows/dna-seq-gatk-variant-calling that is meant to implement the [GATK best-practices workflow](https://gatk.broadinstitute.org/hc/en-us/articles/360035535932-Germline-short-variant-discovery-SNPs-Indels-) for calling small germline variants on Ensembl Metazoa species (the original is for humans), with some tool changes.

## Usage

The usage of this workflow is described in the [Snakemake Workflow Catalog](https://snakemake.github.io/snakemake-workflow-catalog/?usage=snakemake-workflows%2Fdna-seq-gatk-variant-calling).

Quick explanation: 
- Go to the config folder and follow the instructions in there to get started. Should be run with the flag --use-conda to automatically create, manage, and activate the software environments specified in Snakemake rules. Run with the flag --conda-frontend conda if mamba doesn't work (due to new mamba versions issues described in: https://github.com/mamba-org/mamba/issues/3520).
- Starting fastq files should be deposited in a folder called fastq, with the subfolder named after the species (example: fastq/strongyloides_ratti).

If you use this workflow in a paper, don't forget to give credits to the authors by citing the URL of this (original) repository and its DOI (see above).
