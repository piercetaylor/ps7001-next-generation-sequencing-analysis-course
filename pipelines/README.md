# Pipelines

Reusable, staged Bash pipelines from the course (Module 7 and the Module 8
capstone). Each stage is a separate numbered script, so students can run,
check and rerun one step at a time on the HPC.

| Pipeline | Steps | Environment |
|---|---|---|
| [`rnaseq_salmon/`](rnaseq_salmon/README.md) | `0_Salmon_Pipeline_setup.sh` (project and environment), `1_SRA_fetch_fastp_salmon.sh` (SRA download, fastp, Salmon), `2_Run_DESeq2_in_R.sh` (tximport, DESeq2, GO/KEGG) | [`module_3_rnaseq_salmon.yml`](../environment/module_3_rnaseq_salmon.yml) |
| [`rnaseq_star/`](rnaseq_star/README.md) | `0_STAR_Setup.sh`, `1_STAR_Download_and_Align.sh` (SRA, fastp, STAR, featureCounts, bigWig tracks) | [`module_5_star.yml`](../environment/module_5_star.yml) |
| [`dap_seq/`](dap_seq/README.md) | `0_m7_project.sh` to `6_annotate_peaks.sh` (SRA, FastQC/fastp, Bowtie2, Picard/MACS2, deepTools, HOMER/MEME, peak annotation) | [`module_7_dapseq.yml`](../environment/module_7_dapseq.yml) |

> **Note (from the course):** the RNA-seq (STAR and Salmon) pipeline scripts
> and the DAP-seq scripts were developed with help from generative AI as
> educational templates. They are starting points rather than ready-to-run
> code. Before running them, adjust file paths, resource requests (threads,
> memory) and organism-specific settings for your cluster and dataset.
>
> The step tables inside `rnaseq_salmon/README.md` and `rnaseq_star/README.md`
> use earlier script names (for example `0_setup_star_pipeline.sh`). The
> current names are the ones listed above.

The DAP-seq pipeline downloads the public GSE60141 runs listed in
[`data/README.md`](../data/README.md). The RNA-seq pipelines read a
`samples.csv` file of SRR accessions, which you edit for your dataset.
