# Module 4: RNA-seq analysis in R

R for count data: data carpentry, figures with ggplot2, differential expression with DESeq2 (normalization, QC, dispersion, Wald tests, shrinkage) and functional analysis (GO/KEGG over-representation and GSEA), applied to the GSE79275 Cd/iron dataset.

## Learning objectives

- Manipulate count matrices and metadata with base R and the tidyverse
- Build and polish figures with ggplot2 (aesthetic mappings, geoms, facets, scales, labels and themes) and plot DE results (MA, volcano, PCA, heat maps)
- Explain DESeq2 size-factor normalization, dispersion estimation and the negative binomial model
- Run sample-level QC (PCA, hierarchical clustering) and a full DESeq2 analysis
- Perform and interpret GO/KEGG over-representation and gene set enrichment analysis for Arabidopsis

## Assignments

**Labs**

- [M4L1 - Data Carpentry with R](lab/M4L1_Data_carpentry_R.ipynb)
- [M4L2 - Making Figures with ggplot2](lab/M4L2_Graph_Creation_in_R.ipynb)
- [M4L3 - Graphing of RNA-Seq Results in R](lab/M4L3_Graphing_RNA_Seq_Results.ipynb) (CC BY-NC-SA 4.0, see below)
- [M4L4 - RNA-Seq Review](lab/M4L4_RNA_Seq_Review.ipynb)

**Practices**

- [M4P1 - Introduction to Differential Expression Analysis](practice/M4P1_Intro_to_DE_Analysis.ipynb)
- [M4P2 - Functional Analysis](practice/M4P2_Functional_Analysis.ipynb)

**Exercises**

- [M4E1 GSE79275 Arabidopsis Data Analysis](exercise/M4E1_GSE79275_Arabidopsis_Data_Analysis.ipynb)

## Data

`data/geo/GSE79275/GSE79275_raw_read_counts.txt` (`fetch_data.sh geo`), used by M4L2, M4P1, M4P2 and M4E1.

M4L3 uses the human airway tables in `data/airway/` (two committed CSVs, plus `annotables_grch38.csv` from `fetch_data.sh airway_tables`).

M4L1, M4L2, M4L3, M4P1, M4P2 and M4E1 run on a laptop or on Binder after `bash data/fetch_data.sh small`.

See [`data/README.md`](../../data/README.md) for accessions and citations.

## Adapted material

| Notebook / section | Source and license | Changes |
|---|---|---|
| M4L3 and `data/airway/` | [Count-Based Differential Expression Analysis of RNA-seq Data](https://4va.github.io/biodatasci/r-rnaseq-airway.html) by Stephen Turner (4-VA JMU 2017 Biological Data Science Workshop, [4va/biodatasci](https://github.com/4va/biodatasci)), [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/). **M4L3 and its data files are distributed under CC BY-NC-SA 4.0**, not under the repository's all-rights-reserved notice | Reduced to the DESeq2 and plotting sections; worked `ggplot2` MA/volcano code with line-by-line notes; `pheatmap` heat map; paths changed to `data/airway/` |
| M4L4, M4P1, M4P2 | [HBC Introduction to DGE](https://hbctraining.github.io/Intro-to-DGE/) (Harvard Chan Bioinformatics Core (HBC) training materials, [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)) | Example data replaced with the Arabidopsis GSE79275 count matrix (opt3-2/Col-0, with and without Cd); R code adapted to this design. HBC's own figures are kept under CC BY 4.0; figures that HBC reproduces from openly licensed sources (DESeq2 documentation, Paul Pavlidis) are credited under each image, and the rest were removed |

## Not included in the public version

- `Resources/Data_Sci_R_Practice/` (MU Data Science & Analytics notebooks) is not included.

M4L2 was rewritten for the public version. The live-course notebook
followed the `mpg` examples of *R for Data Science* (1st ed., CC BY-NC-ND
3.0); the new notebook uses its own text, examples and exercises built on
GSE79275, and links to R4DS as further reading.
