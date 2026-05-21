import pandas as pd
import os
import glob
from snakemake.utils import validate

report: "report/workflow.rst"

container: "continuumio/miniconda3:4.8.2"

###### Config file and sample sheets #####
configfile: "config/config.yaml"

samples = pd.read_table(config["samples"]).set_index("sample", drop=False)

units = pd.read_table(config["units"], dtype=str).set_index(
    ["sample", "unit"], drop=False
)
units.index = units.index.set_levels(
    [i.astype(str) for i in units.index.levels]
)  # enforce str in index

##### Wildcard constraints #####
wildcard_constraints:
    vartype="snvs|indels",
    sample="|".join(samples.index),
    unit="|".join(units["unit"]),


##### Helper functions #####

def get_trimmed_reads(wildcards):
    """Get trimmed reads of given sample-unit."""
    if not is_single_end(**wildcards):
        # paired-end sample
        return expand(
            "results/trimmed/{sample}-{unit}.{group}.fastq.gz", group=[1, 2], **wildcards
        )
    # single end sample
    return "results/trimmed/{sample}-{unit}.fastq.gz".format(**wildcards)

def get_fastq(wildcards):
    """Get fastq files of given sample-unit."""
    fastqs = units.loc[(wildcards.sample, wildcards.unit), ["fq1", "fq2"]].dropna()
    if len(fastqs) == 2:
        return {"r1": fastqs.fq1, "r2": fastqs.fq2}
    return {"r1": fastqs.fq1}


def is_single_end(sample, unit):
    """Return True if sample-unit is single end."""
    return pd.isnull(units.loc[(sample, unit), "fq2"])


def get_read_group(wildcards):
    """Denote sample name and platform in read group."""
    return r"-R '@RG\tID:{sample}\tSM:{sample}\tPL:{platform}'".format(
        sample=wildcards.sample,
        platform=units.loc[(wildcards.sample, wildcards.unit), "platform"],
    )


def get_sample_bams(wildcards):
    """Get all aligned reads of given sample."""
    return expand(
        "results/dedup/{sample}-{unit}.bam",
        sample=wildcards.sample,
        unit=units.loc[wildcards.sample].unit,
    )

def get_sample_bais(wildcards):
    """Get all aligned reads of given sample."""
    return expand(
        "results/dedup/{sample}-{unit}.bam.bai",
        sample=wildcards.sample,
        unit=units.loc[wildcards.sample].unit,
    )

def get_vartype_arg(wildcards):
    return "--select-type-to-include {}".format(
        "SNP" if wildcards.vartype == "snvs" else "INDEL"
    )

def get_filter(wildcards):
    return {"snv-hard-filter": config["filtering"]["hard"][wildcards.vartype]}
