# Module 5: Genome alignment and genome browsers

Splice-aware genome alignment with STAR, alignment file formats, alignment QC (MultiQC/Qualimap), and visualizing alignments, splice junctions and isoforms in IGV for 12 root samples from GSE128157.

## Learning objectives

- Compare de novo, genome, transcriptome and pseudo-alignment strategies
- Build a STAR index and align RNA-seq reads on the HPC
- Assess alignment quality with MultiQC/Qualimap
- Use IGV to inspect coverage, splice junctions (Sashimi plots) and isoforms (StringTie)

## Assignments

**Overview / start here**

- [Module 5 Checklist](module_5_overview.ipynb)

**Labs**

- [M5L1 - Genome Alignments in RNA-Seq and a Review of File Formats](lab/M5L1_Genome_Alignments_and_File_Formats.ipynb)
- [M5L2 - Data Fetching and Organization](lab/M5L2_Data_Fetching_and_Organization.ipynb)
- [M5L3 - Use of STAR](lab/M5L3_Use_of_STAR.ipynb)

**Practices**

- [M5P1 - IGV Usage](practice/M5P1_IGV_Usage.ipynb)
- [M5P2 IGV on GSE128157](practice/M5P2_IGV_On_GSE128157.ipynb)

**Exercises**

- [M5E1 - IGV Write-up](exercise/M5E1_IGV_Write_Up.ipynb)

## Data

GSE79275 + GSE128156 FASTQs (`fetch_data.sh opt3 cd`); Ensembl Plants release 62 genome and GTF (`fetch_data.sh reference`).

See [`data/README.md`](../../data/README.md) for accessions and citations.

## Adapted material

| Notebook / section | Source and license | Changes |
|---|---|---|
| M5L1, section "How does STAR work?" | [HBC Introduction to RNA-seq using HPC](https://hbctraining.github.io/Intro-to-rnaseq-hpc-O2/) (Harvard Chan Bioinformatics Core (HBC) training materials, [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)) | STAR explanation and figures kept with light edits; applied to Arabidopsis TAIR10 |

## Not included in the public version

- Annotated third-party IGV tutorial slides, figures from ResearchGate-hosted papers, and two IGV screenshots that showed a cluster username were removed.

> **Note:** most notebooks in this module run on an HPC (Hellbender at the University of Missouri, with SLURM) and use large files. Saved outputs were removed for privacy.
