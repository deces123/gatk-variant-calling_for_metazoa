rule trim_reads_se:
    input:
        unpack(get_fastq),
    output:
        temp("results/trimmed/{sample}-{unit}.fastq.gz"),
    params:
        **config["params"]["trimmomatic"]["se"],
        extra="",
    log:
        "logs/trimmomatic/{sample}-{unit}.log",
    wrapper:
        "v5.0.1/bio/trimmomatic/se"


rule trim_reads_pe:
    input:
        unpack(get_fastq),
    output:
        r1=temp("results/trimmed/{sample}-{unit}.1.fastq.gz"),
        r2=temp("results/trimmed/{sample}-{unit}.2.fastq.gz"),
        r1_unpaired=temp("results/trimmed/{sample}-{unit}.1.unpaired.fastq.gz"),
        r2_unpaired=temp("results/trimmed/{sample}-{unit}.2.unpaired.fastq.gz"),
    params:
        **config["params"]["trimmomatic"]["pe"],
    log:
        "logs/trimmomatic/{sample}-{unit}.log",
    wrapper:
        "v5.0.1/bio/trimmomatic/pe"


rule bwa_mem_samblaster:
    input:
        reads=get_trimmed_reads,
        idx=multiext(f"resources/{config['ref']['release']}_{config['ref']['species']}_{config['ref']['build']}/reference.fasta", ".amb", ".ann", ".bwt.2bit.64", ".pac", ".0123"),
    output:
        bam="results/dedup/{sample}-{unit}.bam",
        index="results/dedup/{sample}-{unit}.bam.bai",
    log:
        "logs/bwa_mem_sambamba/{sample}-{unit}.log",
    params:
        extra=r"-R '@RG\tID:{sample}\tSM:{sample}'",
        sort_extra="-q",
    conda:
        "resources/bwa-mem2/environment.yaml"
    benchmark:
        "benchmarks/bwa_mem_sambamba/{sample}-{unit}.txt"
    threads: 8
    script:
        "resources/bwa-mem2/wrapper.py"

