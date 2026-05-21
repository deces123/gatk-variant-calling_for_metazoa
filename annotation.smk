rule get_vep_cache:
    output:
        directory("resources/vep_cache"),
    params:
        species=config["ref"]["species"],
        build=config["ref"]["build"],
        release=config["ref"]["release"],
    conda:
        "resources/vep/cache/environment.yaml"
    log:
        f"logs/vep/{config['ref']['release']}_{config['ref']['species']}_{config['ref']['build']}/cache.log",
    script:
        "resources/vep/cache/wrapper.py"

rule get_vep_plugins:
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

rule annotate_variants:
    input:
        calls=rules.merge_calls.output,
        cache="resources/vep_cache",
        plugins="resources/vep_plugins",
    output:
        calls=report(
            f"results/annotated/{config['ref']['release']}_{config['ref']['species']}_{config['ref']['build']}/all.vcf.gz",
            caption="/report/vcf.rst",
            category="Calls",
        ),
        stats=report(
            f"results/stats/{config['ref']['release']}_{config['ref']['species']}_{config['ref']['build']}/all.stats.html",
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
    threads: 12
    script:
        "resources/vep/annotate/wrapper.py"
