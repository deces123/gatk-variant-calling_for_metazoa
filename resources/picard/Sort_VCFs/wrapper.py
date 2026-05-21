import tempfile
from snakemake.shell import shell

inputs = " ".join("--INPUT {}".format(g) for g in snakemake.input.vcf)
log = snakemake.log_fmt_shell(stdout=False, stderr=True)

with tempfile.TemporaryDirectory() as tmpdir:
    shell(
        "picard SortVcf"
        " {inputs}"
        " --OUTPUT {snakemake.output}"
        " {log}"
    )
