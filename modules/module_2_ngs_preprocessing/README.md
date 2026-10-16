# Module 2: NGS data and pre-processing

Sequencing technologies and data structures, NGS file formats (FASTA/FASTQ/SAM/BAM/GFF), Bash/AWK utilities for large text files, and read QC and trimming with fastp/FastQC, applied to the Arabidopsis iron-homeostasis dataset (GSE128157).

## Learning objectives

- Describe Illumina sequencing-by-synthesis and the main NGS assays (RNA-seq, ChIP-seq, DAP-seq)
- Recognise and parse the common NGS file formats
- Use `grep`, `awk`, `samtools faidx`, `gzip` and related tools to inspect large files
- Run QC and trimming (FastQC, fastp) and interpret the reports
- Organise an NGS project folder reproducibly

## Assignments

**Overview / start here**

- [Module 2 Checklist](module_2_overview.ipynb)

**Labs**

- [M2L1 - NGS Overview](lab/M2L1_NGS_Overview.ipynb)
- [M2L2 - Introduction To Sequencing Techniques and Data Structures](lab/M2L2_Introduction_To_Sequencing_Techniques_And_Data_Structures.ipynb)
- [M2L3 - Use of Hellbender Desktop Via RSSOnDemand](lab/M2L3_Use_Of_Hellbender_Desktop_Via_RSSOnDemand.ipynb)
- [M2L4 - Sequencing File Formats](lab/M2L4_Sequencing_File_Formats.ipynb)

**Practices**

- [M2P1 Pre-Processing Tools](practice/M2P1_Pre_Processing_Tools.ipynb)
- [M2P2 - Bash Utilities practice and AWK usage](practice/M2P2_Bash_Utilities_Practice_and_AWK.ipynb)
- [M2P3 Trimming and Quality Control](practice/M2P3_Trimming_And_Quality_Control.ipynb)

**Exercises**

- [NGS Data Organization and Storage Strategy](exercise/M2E1_Storage_of_Sequencing_And_Genomic_Data.ipynb)
- [M2E3 - Preprocessing](exercise/M2E2_Pre_Processing.ipynb)

**Resources**

- [M2 Loading Global Enviornments](resources/M2_Loading_Global_Environments.ipynb)

**Other material**

- [Demo scripts](resources/demo_scripts/README.md)

## Data

GSE79275 root FASTQs (`fetch_data.sh opt3`); practice files (`fetch_data.sh practice`); Ensembl Plants TAIR10 cDNA.

See [`data/README.md`](../../data/README.md) for accessions and citations.

## Adapted material

| Notebook / section | Source and license | Changes |
|---|---|---|
| M2L2, Illumina cluster-generation figure | ["Cluster Generation.png"](https://commons.wikimedia.org/wiki/File:Cluster_Generation.png) by DMLapato, Wikimedia Commons, [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) | Unchanged; linked from Wikimedia Commons (not stored here) and credited under the image |
| M2P1, FastQC example plots | [Computational Genomics Tutorial](https://genomics.sschmeier.com/) by Sebastian Schmeier ([sschmeier/genomics](https://github.com/sschmeier/genomics)), MIT License | Unchanged; linked from the tutorial site (not stored here) and credited under the images |

## Not included in the public version

- The RNA-seq workflow figures `M2P1RNASeqPipeline.png` and `M2P3PreprocessingSteps.png` were removed because the original source could not be confirmed.
- The example paired FASTQ files and a vendor plasmid GenBank file had no recorded public source. The FASTQ files are regenerated from a public run by `fetch_data.sh practice`.

> **Note:** most notebooks in this module run on an HPC (Hellbender at the University of Missouri, with SLURM) and use large files. Saved outputs were removed for privacy.
