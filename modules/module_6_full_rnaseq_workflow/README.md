# Module 6: Full RNA-seq workflow

Putting the pieces together: HPC computing concepts (SLURM, storage, SSH), project management and scripting, RStudio on the HPC, DESeq2 interaction designs, and an independent full STAR + DESeq2 analysis of GSE72548.

## Learning objectives

- Submit and monitor SLURM jobs and choose appropriate resources
- Organise reproducible NGS projects and transfer data (Globus/rsync)
- Run R/RStudio on the HPC
- Model genotype x treatment interactions in DESeq2
- Carry out a complete RNA-seq analysis on a new public dataset

## Assignments

**Overview / start here**

- [Module 6 Checklist](module_6_overview.ipynb)

**Labs**

- [M6L1 - Review of Computing Concepts](lab/M6L1_Review_of_Computing_Concepts.ipynb)
- [M6L2 - Project Management Review](lab/M6L2_Project_Management_Review.ipynb)
- [M6L3 Use of R-Studio](lab/M6L3_Use_Of_Rstudio.ipynb)

**Practices**

- [M6P1 - Pipelines and Scripting for RNA-Seq](practice/M6P1_Pipelines_and_Scripting_for_RNA_Seq.ipynb)
- [M6P2 Interactions and Study Design for DESeq2](practice/M6P2_Interactions_and_Study_Design_for_DESeq2.ipynb)

**Exercises**

- [M6E1 - Full RNA-Seq Analysis](exercise/M6E1_Full_RNA_Seq_Analysis.ipynb)

## Data

GSE79275 counts (`fetch_data.sh geo`); GSE72548 FASTQs (`fetch_data.sh gse72548`).

See [`data/README.md`](../../data/README.md) for accessions and citations.

## Adapted material

| Notebook / section | Source and license | Changes |
|---|---|---|
| M6P2 | [HBC Introduction to DGE](https://hbctraining.github.io/Intro-to-DGE/) (Harvard Chan Bioinformatics Core (HBC) training materials, [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)) | Applied to the GSE79275 genotype x treatment design with interaction terms |

## Not included in the public version

- Globus documentation screenshots (one showed a third party's name and email) and RStudio/terminal screenshots that showed cluster usernames were removed.

> **Note:** most notebooks in this module run on an HPC (Hellbender at the University of Missouri, with SLURM) and use large files. Saved outputs were removed for privacy.
