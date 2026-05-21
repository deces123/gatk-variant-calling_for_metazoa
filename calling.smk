rule call_variants:
    input:
        bam=get_sample_bams,
        ref=rules.get_genome.output,
        idx=rules.genome_dict.output,
        fai=rules.genome_faidx.output,
        bai=get_sample_bais,
    output:
        gvcf="results/called/{sample}.g.vcf.gz",
    log:
        "logs/gatk/haplotypecaller/{sample}.log",
    params:
        extra=config["params"]["gatk"]["HaplotypeCaller"],
    resources:
        mem_mb=lambda wildcards, input: input.size_mb * 0.6,
    wrapper:
        "v5.0.1/bio/gatk/haplotypecaller"  
        
rule get_intervals:
    input:
        gvcf=expand(
            "results/called/{sample}.g.vcf.gz", sample=samples.index
        ),
    output:
        f"resources/{config['ref']['release']}_{config['ref']['species']}_{config['ref']['build']}/chromosome.list",
    conda:
        "resources/bcftools/environment.yaml"
    shell:
        """
        first_sample=$(awk 'NR==2 {{print $1}}' config/samples.tsv);
        bcftools query -f '%CHROM\\n' "results/called/${{first_sample}}.g.vcf.gz" | sort -u > {output}
        """

rule genomicsdb_import:
    input:
        ref=rules.get_genome.output,
        gvcfs=expand(
            "results/called/{sample}.g.vcf.gz", sample=samples.index
        ),
        intervals=rules.get_intervals.output,
    output:
        db=directory(f"results/genomicsdb/{config['ref']['release']}_{config['ref']['species']}_{config['ref']['build']}"),
    params:
        extra=config["params"]["gatk"]["GenomicsDBImport"],  # Any additional parameters
        db_action="create"  # Can be "create" or "update"
    log: 
        f"logs/GenomicsDBImport/{config['ref']['release']}_{config['ref']['species']}_{config['ref']['build']}/genomicsDBimport.log",
    wrapper:
        "v5.0.1/bio/gatk/genomicsdbimport" 

rule genotype_variants:
    input:
        ref=rules.get_genome.output,
        genomicsdb=rules.genomicsdb_import.output,
    output:
        vcf=f"results/genotyped/{config['ref']['release']}_{config['ref']['species']}_{config['ref']['build']}/all.vcf.gz",
    params:
        extra=config["params"]["gatk"]["GenotypeGVCFs"],
    log:
        f"logs/GenotypeGVCFs/{config['ref']['release']}_{config['ref']['species']}_{config['ref']['build']}/genotypeGVCFs.log",
    wrapper:
        "v5.0.1/bio/gatk/genotypegvcfs"