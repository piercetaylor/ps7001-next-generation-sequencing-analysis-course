# Conda environments

The live course had 15 environment files (including checkpoint copies),
spread across module folders. They are deduplicated here into five
environments. Environment names are kept as they were so the notebooks still
work.

| File | Environment name | Used in | Also known in the course as |
|---|---|---|---|
| [`module_1.yml`](module_1.yml) | `Module_1` | Module 1 (Bash, BLAST via R/IRkernel) | |
| [`module_3_rnaseq_salmon.yml`](module_3_rnaseq_salmon.yml) | `Module_3_Local_Env` | Modules 3, 4, 6 (fastp, Salmon, DESeq2, tximport, clusterProfiler, Bash and R kernels) | `Module_3_Bash_and_R_kernel.yml`, `pseudo_alignment_pipeline_env.yml` (`Salmon_Pipeline`) |
| [`module_5_star.yml`](module_5_star.yml) | `module_5_STAR` | Modules 5, 6, `pipelines/rnaseq_star` | `alignemnt_STAR_pipeline_env.yml` |
| [`module_5_igv.yml`](module_5_igv.yml) | `module_5_IGV` | Module 5 (IGV, StringTie, rMATS, regtools) | `IGV_env.yml` |
| [`module_7_dapseq.yml`](module_7_dapseq.yml) | `module_7_dapseq` | Module 7, `pipelines/dap_seq` (Bowtie2, MACS2, deepTools, HOMER, MEME) | `dapseq_env.yml` (`dapseq_env`) |

## Quick start

```bash
# with mamba (recommended) or conda
mamba env create -f environment/module_3_rnaseq_salmon.yml
mamba activate Module_3_Local_Env

# register Jupyter kernels from inside the environment
python -m bash_kernel.install --sys-prefix
R -e "IRkernel::installspec(name = 'Module_3_R', displayname = 'Module 3 - R')"
```

On Hellbender, load mamba first with `module load mamba`. Package versions
are not pinned (except `r-base=4.3` and `python=3.10` where the course pinned
them). Pin them with `mamba env export` when you need exact reproducibility.

The lightweight environment for running the R notebooks on Binder is in
[`binder/environment.yml`](../binder/environment.yml).
