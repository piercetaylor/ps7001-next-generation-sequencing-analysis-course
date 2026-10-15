# Module 4: RNA-seq analysis in R

R for count data: data carpentry, differential expression with DESeq2 (normalization, QC, dispersion, Wald tests, shrinkage) and functional analysis (GO/KEGG over-representation and GSEA), applied to the GSE79275 Cd/iron dataset.

## Learning objectives

- Manipulate count matrices and metadata with base R and the tidyverse
- Explain DESeq2 size-factor normalization, dispersion estimation and the negative binomial model
- Run sample-level QC (PCA, hierarchical clustering) and a full DESeq2 analysis
- Perform and interpret GO/KEGG over-representation and gene set enrichment analysis for Arabidopsis

## Assignments

**Labs**

- [M4L1 - Data Carpentry with R](lab/M4L1_Data_carpentry_R.ipynb)
- [M4L4 - RNA-Seq Review](lab/M4L4_RNA_Seq_Review.ipynb)

**Practices**

- [M4P1 - Introduction to Differential Expression Analysis](practice/M4P1_Intro_to_DE_Analysis.ipynb)
- [M4P2 - Functional Analysis](practice/M4P2_Functional_Analysis.ipynb)

**Exercises**

- [M4E1 GSE79275 Arabidopsis Data Analysis](exercise/M4E1_GSE79275_Arabidopsis_Data_Analysis.ipynb)

## Data

`data/geo/GSE79275/GSE79275_raw_read_counts.txt` (`fetch_data.sh geo`).

See [`data/README.md`](../../data/README.md) for accessions and citations.

## Adapted material

| Notebook / section | Source and license | Changes |
|---|---|---|
| M4L4, M4P1, M4P2 | [HBC Introduction to DGE](https://hbctraining.github.io/Intro-to-DGE/) (Harvard Chan Bioinformatics Core (HBC) training materials, [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)) | Example data replaced with the Arabidopsis GSE79275 count matrix (opt3-2/Col-0, with and without Cd); R code adapted to this design; third-party figures that HBC reproduces were removed |

## Not included in the public version

- M4L2 "Graph creation in R" adapted examples from *R for Data Science* (1st ed.), which is CC BY-NC-ND 3.0, so it is not included.
- M4L3 "Graphing RNA-seq results" was adapted from the UVA *biodatasci* course (4va/biodatasci, CC BY-NC-SA 4.0) and used its `airway` CSV files, so it is not included.
- `Resources/Data_Sci_R_Practice/` (MU Data Science & Analytics notebooks) is not included.
