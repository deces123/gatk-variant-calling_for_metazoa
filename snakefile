include: "common.smk"

rule all:
    input:
        f"results/qc/{config['ref']['release']}_{config['ref']['species']}_{config['ref']['build']}/multiqc.html",
        f"results/stats/{config['ref']['release']}_{config['ref']['species']}_{config['ref']['build']}/all.stats.html",
        f"results/filtered/{config['ref']['release']}_{config['ref']['species']}_{config['ref']['build']}/vcf.gz",
        f"results/plots/{config['ref']['release']}{config['ref']['species']}{config['ref']['build']}/depths.svg",
        f"results/plots/{config['ref']['release']}{config['ref']['species']}{config['ref']['build']}/allele-freqs.svg",
        

##### Modules #####

include: "ref.smk"
include: "mapping.smk"
include: "calling.smk"
include: "filtering.smk"
include: "qc.smk"
include: "stats.smk"
include: "annotation.smk"