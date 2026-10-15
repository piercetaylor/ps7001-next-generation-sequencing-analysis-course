# Module 3: RNA-seq I, pseudo-alignment

Sourcing RNA-seq data from GEO/SRA, QC with fastp, transcript quantification with Salmon, and a first DESeq2 analysis, using opt3-2 vs Col-0 root samples from GSE79275.

## Learning objectives

- Map GEO sample (GSM) accessions to SRA runs and download FASTQs with the SRA Toolkit/Entrez Direct
- Explain pseudo-alignment and expectation-maximization for transcript quantification
- Build a Salmon index and quantify samples on the HPC
- Import Salmon output into R with tximport and run an initial DESeq2 analysis

## Assignments

**Labs**

- [M3L1 - RNA-Seq (Pseudo-Alignment) Overview](lab/M3L1_RNA_Seq_Overview.ipynb)
- [M3L2 - Sourcing Data For Analysis Pipelines](lab/M3L2_Sourcing_Data_For_Analysis_Pipelines.ipynb)

**Practices**

- [M3P1 - fastp on Arabidopsis OPT3 and Col-0 Dataset](practice/M3P1_Fastp_on_Arabidopsis_OPT3_Dataset.ipynb)
- [M3P2 - Pseudo-Alignment on Arabidopsis OPT3 Dataset using salmon](practice/M3P2_Pseudo_Alignment_on_Arabidopsis_OPT3_Dataset.ipynb)

**Exercises**

- [M3E1 - Results Analysis on Arabidopsis Data with DESeq2](exercise/M3E1_RNA_Seq_Analysis.ipynb)

**Other material**

- [Demo scripts](resources/demo_scripts/README.md)

## Data

GSE79275 FASTQs (`fetch_data.sh opt3`); TAIR10 cDNA blast set, GFF3 and cDNA associations (`fetch_data.sh reference`).

See [`data/README.md`](../../data/README.md) for accessions and citations.

## Adapted material

| Notebook / section | Source and license | Changes |
|---|---|---|
| M3L1 expectation-maximization walkthrough | Appears to follow teaching material by Alexander Lachmann. **Source and license to be confirmed** | Figures removed; text and toy code kept pending confirmation |

## Not included in the public version

- The completed DESeq2 R script for M3E1 (`m3_project_pseudo_alignment/scripts/RScript.txt`) is not included because it is a solution.
- Three EM illustration figures and two workflow figures from unconfirmed third-party sources were removed.

> **Note:** most notebooks in this module run on an HPC (Hellbender at the University of Missouri, with SLURM) and use large files. Saved outputs were removed for privacy.
