# Module 8: Capstone and reference

The final project: students choose a public dataset and run a complete RNA-seq (Salmon or STAR) or DAP-seq/ChIP-seq analysis using the reusable pipelines and environments from the course.

## Learning objectives

- Select a public dataset with a sound experimental design
- Adapt a course pipeline to a new organism or dataset
- Report methods, results and limitations reproducibly

## Assignments

**Overview / start here**

- [Module 8 Final Project](module_8_final_project.ipynb)

**Optional:** [single-cell RNA-seq lab and practice](../module_8_scRNA_Seq_OPTIONAL/README.md) (10x, STARsolo, Seurat)

## Reference notebooks (formerly `Tutorials/`)

**DE analysis**

- [M4P1 - Introduction to Differential Expression Analysis](../module_4_rnaseq_in_r/practice/M4P1_Intro_to_DE_Analysis.ipynb)
- [M4P2 - Functional Analysis](../module_4_rnaseq_in_r/practice/M4P2_Functional_Analysis.ipynb)
- [M6P2 Interactions and Study Design for DESeq2](../module_6_full_rnaseq_workflow/practice/M6P2_Interactions_and_Study_Design_for_DESeq2.ipynb)

**R tutorials**

- [M4L1 - Data Carpentry with R](../module_4_rnaseq_in_r/lab/M4L1_Data_carpentry_R.ipynb)
- [M4L4 - RNA-Seq Review](../module_4_rnaseq_in_r/lab/M4L4_RNA_Seq_Review.ipynb)
- [M6L3 Use of R-Studio](../module_6_full_rnaseq_workflow/lab/M6L3_Use_Of_Rstudio.ipynb)

**SRA usage and project folder setup**

- [M3L2 - Sourcing Data For Analysis Pipelines](../module_3_rnaseq_pseudoalignment/lab/M3L2_Sourcing_Data_For_Analysis_Pipelines.ipynb)
- [M5L2 - Data Fetching and Organization](../module_5_genome_alignment/lab/M5L2_Data_Fetching_and_Organization.ipynb)
- [M6L2 - Project Management Review](../module_6_full_rnaseq_workflow/lab/M6L2_Project_Management_Review.ipynb)
- [M6P1 - Pipelines and Scripting for RNA-Seq](../module_6_full_rnaseq_workflow/practice/M6P1_Pipelines_and_Scripting_for_RNA_Seq.ipynb)

**Trimming and QC metrics**

- [M3P1 - fastp on Arabidopsis OPT3 and Col-0 Dataset](../module_3_rnaseq_pseudoalignment/practice/M3P1_Fastp_on_Arabidopsis_OPT3_Dataset.ipynb)

**Using Salmon**

- [M3P2 - Pseudo-Alignment on Arabidopsis OPT3 Dataset using salmon](../module_3_rnaseq_pseudoalignment/practice/M3P2_Pseudo_Alignment_on_Arabidopsis_OPT3_Dataset.ipynb)

**Using STAR**

- [M5L3 - Use of STAR](../module_5_genome_alignment/lab/M5L3_Use_of_STAR.ipynb)

## Pipelines and environments

- [Pipelines: Salmon RNA-seq, STAR RNA-seq, DAP-seq](../../pipelines/README.md)
- [Conda environments](../../environment/README.md)

## Data

Student-selected public datasets.

See [`data/README.md`](../../data/README.md) for accessions and citations.

## Not included in the public version

- The `Tutorials/` folder in the live course held copies of notebooks from Modules 3 to 6. Here they are linked from their home modules instead (see below). The Module 8 copy of M5L3 differed only in its scratch-directory setting and saved outputs.
