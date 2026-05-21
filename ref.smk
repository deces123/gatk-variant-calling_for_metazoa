rule get_genome:
    output:
        f"resources/{config['ref']['release']}_{config['ref']['species']}_{config['ref']['build']}/reference.fasta",
    log:
        f"logs/reference/{config['ref']['release']}_{config['ref']['species']}_{config['ref']['build']}/get-genome.log",
    params:
        species=config["ref"]["species"],
        datatype="dna",
        build=config["ref"]["build"],
        release=config["ref"]["release"],
    cache: True
    conda:
        "reference/ensembl-sequence/environment.yaml"
    script:
        "reference/ensembl-sequence/wrapper.py"

checkpoint genome_faidx:
    input:
        rules.get_genome.output,
    output:
        f"resources/{config['ref']['release']}_{config['ref']['species']}_{config['ref']['build']}/reference.fasta.fai", 
    log:
        f"logs/reference/{config['ref']['release']}_{config['ref']['species']}_{config['ref']['build']}/genome-faidx.log",
    cache: True
    wrapper:
        "v5.0.1/bio/samtools/faidx"

rule genome_dict:
    input:
        rules.get_genome.output,
    output:
        f"resources/{config['ref']['release']}_{config['ref']['species']}_{config['ref']['build']}/reference.dict",
    log:
        f"logs/reference/{config['ref']['release']}_{config['ref']['species']}_{config['ref']['build']}/create_dict.log",
    conda:
        "envs/samtools.yaml"
    cache: True
    shell:
        "samtools dict {input} -o {output}"

rule bwa_index:
    input:
        rules.get_genome.output,
    output:
        multiext(f"resources/{config['ref']['release']}_{config['ref']['species']}_{config['ref']['build']}/reference.fasta", ".amb", ".ann", ".bwt.2bit.64", ".pac", ".0123"),
    log:
        f"logs/reference/{config['ref']['release']}_{config['ref']['species']}_{config['ref']['build']}/bwa_index.log",
    resources:
        mem_mb=369,
    cache: True
    wrapper:
        "v5.0.1/bio/bwa-mem2/index"
