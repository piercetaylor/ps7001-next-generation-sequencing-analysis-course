# Module 7: DAP-seq

Protein-DNA interaction assays (DAP-seq, ChIP-seq, ATAC-seq) and a scripted DAP-seq pipeline (QC, Bowtie2, MACS2 peak calling against a beads-only control, deepTools, HOMER/MEME motifs, peak annotation) for Arabidopsis ARF transcription factors from GSE60141.

## Learning objectives

- Explain DAP-seq, ChIP-seq and ATAC-seq experimental designs and controls
- Run a staged, scripted DAP-seq pipeline on the HPC
- Call and interpret peaks (narrowPeak, FRiP) and discover motifs
- Visualise peaks and coverage in IGV and relate them to published results

## Assignments

**Labs**

- [M7 - DAP-Seq Overview](lab/M7L1_DAP_Seq_Overview.ipynb)
- [M7L2 - DAP-Seq: Interpreting Results](lab/M7L2_DAP_Seq_Interpreting_Results.ipynb)
- [M7L3 DAP-Seq Analysis Pipeline](lab/M7L3_DAP_Seq_Analysis_Pipeline.ipynb)

**Practices**

- [M7P1 DAP-Seq Analysis Scripted](practice/M7P1_DAP_Seq_Analysis_Scripted.ipynb)

**Exercises**

- [M7E1 - DAP-Seq IGV Usage](exercise/M7E1_DAP_Seq_IGV_Usage.ipynb)

**Other material**

- [Example figures](figures/README.md)

The DAP-seq pipeline scripts used in M7P1 are in [`pipelines/dap_seq/`](../../pipelines/dap_seq/README.md).

## Data

GSE60141 DAP-seq FASTQs (`fetch_data.sh dapseq`); GSE60141 ARF5 narrowPeak (`fetch_data.sh geo`); Ensembl Plants TAIR10 genome.

See [`data/README.md`](../../data/README.md) for accessions and citations.

## Adapted material

| Notebook / section | Source and license | Changes |
|---|---|---|
| M7L3 (QC and MACS2 sections) | [HBC Introduction to ChIP-seq](https://hbctraining.github.io/Intro-to-ChIPseq/) (Harvard Chan Bioinformatics Core (HBC) training materials, [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)) | Rewritten for DAP-seq of ARF transcription factors with a beads-only control |

## Not included in the public version

- Figures from O'Malley et al. (2016) *Cell* and Bartlett et al. (2017) *Nature Protocols* (both all rights reserved), and figures from vendor and education websites, were removed and replaced with citations.

> **Note:** most notebooks in this module run on an HPC (Hellbender at the University of Missouri, with SLURM) and use large files. Saved outputs were removed for privacy.
