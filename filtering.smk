rule select_calls:
    input:
        ref=rules.get_genome.output,
        vcf=rules.genotype_variants.output,
    output:
        vcf=temp("results/filtered/all.{vartype}.vcf.gz"),
    params:
        extra=get_vartype_arg,
    log:
        "logs/gatk/selectvariants/{vartype}.log",
    wrapper:
        "v5.0.1/bio/gatk/selectvariants"

rule hard_filter_calls:
    input:
        ref=rules.get_genome.output,
        vcf="results/filtered/all.{vartype}.vcf.gz",
    output:
        vcf=temp("results/filtered/all.{vartype}.hardfiltered.vcf.gz"),
    params:
        filters=get_filter,
    log:
        "logs/gatk/variantfiltration/{vartype}.log",
    wrapper:
        "v5.0.1/bio/gatk/variantfiltration"
        
rule sort_vcf:
    input:
        vcf=expand(
            "results/filtered/all.{vartype}.hardfiltered.vcf.gz",
            vartype=["snvs", "indels"],
            ),
    output:
        temp("results/filtered/{vartype}.vcf.gz"),
    log:
        "logs/picard/{vartype}_sortedsnps.log",
    conda:
        "resources/picard/Sort_VCFs/environment.yaml",
    script:
        "resources/picard/Sort_VCFs/wrapper.py"

        
rule merge_calls:
    input:
        vcfs=expand(
            "results/filtered/{vartype}.vcf.gz",
            vartype=["snvs", "indels"],
        ),
    output:
        vcf=f"results/filtered/{config['ref']['release']}_{config['ref']['species']}_{config['ref']['build']}/vcf.gz",
    log:
        f"logs/picard/{config['ref']['release']}_{config['ref']['species']}_{config['ref']['build']}/merged.log",
    wrapper:
        "v5.0.1/bio/picard/mergevcfs"