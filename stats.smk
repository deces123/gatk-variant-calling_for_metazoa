rule vcf_to_tsv:
    input:
        rules.merge_calls.output,
    output:
        report(
            f"results/tables/{config['ref']['release']}{config['ref']['species']}{config['ref']['build']}/calls.tsv",
            caption="report/calls.rst",
            category="Calls",
        ),
    log:
        f"logs/vcf-to-tsv.{config['ref']['release']}{config['ref']['species']}{config['ref']['build']}.log",
    conda:
        "envs/rbt.yaml",
    shell:
        "(bcftools view --apply-filters PASS --output-type z {input} | "
        "rbt vcf-to-txt -g --fmt DP AD --info ANN | "
        "gzip > {output}) 2> {log}"

rule plot_stats:
    input:
        rules.vcf_to_tsv.output,
    output:
        depths=report(
            f"results/plots/{config['ref']['release']}{config['ref']['species']}{config['ref']['build']}/depths.svg", 
            caption="report/depths.rst", 
            category="Plots",
        ),
        freqs=report(
            f"results/plots/{config['ref']['release']}{config['ref']['species']}{config['ref']['build']}/allele-freqs.svg",
            caption="report/freqs.rst",
            category="Plots",
        ),
    log:
        f"logs/plot-stats.{config['ref']['release']}{config['ref']['species']}{config['ref']['build']}.log",
    conda:
        "envs/stats.yaml",
    script:
        "scripts/plot-depths.py"