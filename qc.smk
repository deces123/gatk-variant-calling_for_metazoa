rule fastqc:
    input:
        unpack(get_fastq),
    output:
        html="results/qc/fastqc/{sample}-{unit}.html",
        zip="results/qc/fastqc/{sample}-{unit}.zip",
    log:
        "logs/fastqc/{sample}-{unit}.log",
    wrapper:
        "v5.0.1/bio/fastqc"


rule samtools_stats:
    input:
        "results/dedup/{sample}-{unit}.bam",
    output:
        "results/qc/samtools-stats/{sample}-{unit}.txt",
    log:
        "logs/samtools-stats/{sample}-{unit}.log",
    wrapper:
        "v5.0.1/bio/samtools/stats"


rule multiqc:
    input:
        expand(
            [
                "results/qc/samtools-stats/{u.sample}-{u.unit}.txt",
                "results/qc/fastqc/{u.sample}-{u.unit}.zip",
                "results/qc/dedup/{u.sample}-{u.unit}.metrics.txt",
            ],
            u=units.itertuples(),
        ),
    output:
        report(
            f"results/qc/{config['ref']['release']}_{config['ref']['species']}_{config['ref']['build']}/multiqc.html",
            caption="report/multiqc.rst",
            category="Quality control",
        ),
    log:
        "logs/multiqc.log",
    wrapper:
        "v5.0.1/bio/multiqc"