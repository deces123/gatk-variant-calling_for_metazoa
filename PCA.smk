rule haplotype_block_detection:
    input:
        writehere
    output:
        directory("resources/vep_cache"),
    params:
        
    conda:
        "resources/vep/cache/environment.yaml"
    log:
        "logs/vep/cache.log",
    script:
        "resources/vep/cache/wrapper.py"

rule LD_pruning:
    input:
        writehere
    output:
        directory("resources/vep_plugins"),
    log:
        "logs/vep/plugins.log",
    params:
        release=config["params"]["vep"]["release"],
    conda:
        "resources/vep/plugins/environment.yaml"
    script:
        "resources/vep/plugins/wrapper.py"

rule PCA_drawing:
    input:
        calls="results/filtered/allsnps.vcf.gz",
        cache="resources/vep_cache",
        plugins="resources/vep_plugins",
    output:
        calls=report(
            "results/annotated/all.vcf.gz",
            caption="/report/vcf.rst",
            category="Calls",
        ),
        stats=report(
            "results/stats/all.stats.html",
            caption="/report/stats.rst",
            category="Calls",
        ),
    params:
        # Pass a list of plugins to use, see https://www.ensembl.org/info/docs/tools/vep/script/vep_plugins.html
        # Plugin args can be added as well, e.g. via an entry "MyPlugin,1,FOO", see docs.
        plugins=config["params"]["vep"]["plugins"],
        extra=config["params"]["vep"]["extra"],
    conda:
        "resources/vep/annotate/environment.yaml"
    log:
        "logs/vep/annotate.log",
    threads: 4
    script:
        "resources/vep/annotate/wrapper.py"
