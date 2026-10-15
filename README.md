# PS4001/PS7001: Next-Generation Sequencing Analysis

A project-based course on analyzing high-throughput sequencing data: Linux
and Bash on an HPC cluster, RNA-seq (pseudo-alignment and genome
alignment), differential expression and functional analysis in R, and
protein-DNA binding (DAP-seq/ChIP-seq). The course was written for the
**Hellbender HPC cluster at the University of Missouri**. Most exercises run
on public *Arabidopsis thaliana* iron-homeostasis and cadmium datasets.

**Author:** Pierce Taylor

> This repository is a portfolio copy of the course. Answer keys, grading
> material and student work are not included. Some lessons were adapted
> from openly licensed material; see [Adapted teaching materials](#adapted-teaching-materials).

## Audience and learning outcomes

Upper-level undergraduate (PS4001) and graduate (PS7001) students in the
plant and life sciences, with little or no programming background. By the
end of the course students can:

- work on a shared HPC cluster: navigate Linux, write Bash scripts, manage
  conda environments, and submit and monitor SLURM jobs;
- find, download and organise public sequencing data (GEO/SRA/ENA) in a
  reproducible project layout;
- quality-check and trim reads (FastQC, fastp, MultiQC);
- quantify RNA-seq with pseudo-alignment (Salmon) and with splice-aware
  genome alignment (STAR), and inspect the alignments in IGV;
- run and interpret differential expression (DESeq2, including interaction
  designs) and functional enrichment (GO/KEGG ORA, GSEA) in R;
- run a DAP-seq/ChIP-seq workflow (Bowtie2, MACS2, deepTools, HOMER/MEME)
  and relate the peaks and motifs to biology;
- carry out an independent capstone analysis on a dataset of their choice.

## Modules

| Module | Topic | Key assignments |
|---|---|---|
| [0](modules/module_0_orientation/README.md) | Orientation | Prompting AI tools responsibly, computing and NGS resources |
| [1](modules/module_1_bash_hpc/README.md) | Bash and HPC basics | Bash on Hellbender, conda environments, Bash scripting, BLAST scripting |
| [2](modules/module_2_ngs_preprocessing/README.md) | NGS data and pre-processing | Sequencing techniques, file formats, AWK/Bash utilities, fastp trimming and QC |
| [3](modules/module_3_rnaseq_pseudoalignment/README.md) | RNA-seq I: pseudo-alignment | Sourcing data from GEO/SRA, fastp, Salmon, first DESeq2 analysis |
| [4](modules/module_4_rnaseq_in_r/README.md) | RNA-seq in R | Data carpentry, ggplot2 figures, plotting DE results, DE analysis, functional analysis (GSE79275) |
| [5](modules/module_5_genome_alignment/README.md) | Genome alignment | Alignment formats, STAR, IGV (GSE128157) |
| [6](modules/module_6_full_rnaseq_workflow/README.md) | Full RNA-seq workflow | HPC review, pipelines, RStudio, DESeq2 study design, independent analysis (GSE72548) |
| [7](modules/module_7_dap_seq/README.md) | DAP-seq | DAP/ChIP/ATAC overview, MACS2 peak calling, motifs, annotation, IGV (GSE60141) |
| [8](modules/module_8_capstone/README.md) | Capstone and reference | Final project, reusable Salmon/STAR/DAP-seq pipelines and environments |

Start with [`modules/start_here.ipynb`](modules/start_here.ipynb). Each
module folder has a README with learning objectives and links to its labs,
practices and exercises.

## Tools taught

Bash, SLURM, conda/mamba, Jupyter, SRA Toolkit and Entrez Direct, FastQC,
fastp, MultiQC, BLAST+, Salmon, STAR, SAMtools, BEDTools, Qualimap, IGV,
StringTie, R (tidyverse, ggplot2, DESeq2, tximport, clusterProfiler), RStudio,
Bowtie2, Picard, MACS2, deepTools, HOMER, MEME Suite, and an introduction
to nf-core/Nextflow and Galaxy.

## Repository layout

```
modules/        teaching notebooks: module_N_<topic>/{lab,practice,exercise,resources}/
pipelines/      staged Bash pipelines: rnaseq_salmon/, rnaseq_star/, dap_seq/
environment/    deduplicated conda environment files
data/           README with accessions and citations, fetch_data.sh, small committed examples, airway/ (M4L3, CC BY-NC-SA 4.0)
LICENSES/       full text of third-party licenses (CC BY-NC-SA 4.0)
tools/          course-operations scripts (weekly deployment, answer release) and check_links.py
binder/         lightweight environment for running the R notebooks on Binder
_config.yml, _toc.yml   Jupyter Book site configuration
```

## Getting started

The notebooks are meant to be **read** on GitHub or on the Jupyter Book
site. They were built to **run** on an HPC.

```bash
git clone https://github.com/piercetaylor/ps7002-next-generation-sequencing-analysis-course.git
cd ps7002-next-generation-sequencing-analysis-course

# path variables used in the notebooks and scripts
export REPO_DIR="$PWD"              # this repository
export DATA_DIR="$REPO_DIR/data"    # downloaded and example data (the default when unset)
export WORK_DIR="$HOME/ngs_course"  # your working folder (on Hellbender this was a per-student course folder)

# create an environment (see environment/README.md)
mamba env create -f environment/module_3_rnaseq_salmon.yml

# download public data (see data/README.md for sizes)
bash data/fetch_data.sh small       # count tables for the R notebooks
bash data/fetch_data.sh opt3        # RNA-seq FASTQs (HPC)
```

- **Lightweight R notebooks** (M4L1, M4L2, M4L3, M4P1, M4P2, M4E1, M6P2) run on a
  laptop or on Binder. Binder installs `binder/environment.yml` and
  downloads the GEO count tables and the M4L3 airway annotation automatically.
- **HPC notebooks** have a "Runs on an HPC" note at the top. They expect
  SLURM, `module load mamba`, 8+ cores and 32+ GB RAM, and FASTQ files in the
  tens of GB.

Path conventions: hard-coded cluster paths from the live course were
replaced with `REPO_DIR`, `DATA_DIR`, `WORK_DIR`, `PROJECT_DIR` (a project
folder made inside a module), `CLASS_DIR` (course root, deployment scripts
only) and `HOME`.

## Data sources and attributions

All sequencing data are public and are downloaded, not committed:

| Dataset | Used for | Reference |
|---|---|---|
| [GSE79275](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE79275) (opt3-2 vs Col-0, roots/leaves) | Modules 2 to 6 | Khan et al. 2018, *Plant Cell Environ.* [doi:10.1111/pce.13192](https://doi.org/10.1111/pce.13192) |
| [GSE128156](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE128156) / [GSE128157](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE128157) (cadmium) | Modules 2, 5 | McInturf et al. 2022, *J Exp Bot.* [doi:10.1093/jxb/erab393](https://doi.org/10.1093/jxb/erab393) |
| [GSE60143](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE60143) / GSE60141 (DAP-seq, ARF TFs) | Module 7 | O'Malley et al. 2016, *Cell.* [doi:10.1016/j.cell.2016.04.038](https://doi.org/10.1016/j.cell.2016.04.038) |
| [GSE72548](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE72548) (cytokinin, nematode) | Module 6 | Shanks et al. 2016, *MPMI.* [doi:10.1094/MPMI-07-15-0156-R](https://doi.org/10.1094/MPMI-07-15-0156-R) |
| SRR1971253 | Module 2 practice | Tan et al. 2015, *eLife* (citation to be confirmed) |
| GSE52778 / Bioconductor `airway` (tables from 4va/biodatasci, CC BY-NC-SA 4.0) | Module 4 (M4L3) | Himes et al. 2014, *PLoS One.* [doi:10.1371/journal.pone.0099625](https://doi.org/10.1371/journal.pone.0099625) |
| Ensembl Plants release 62 TAIR10; TAIR10 blast sets | References | Yates et al. 2022; Lamesch et al. 2012 |

Full accessions, run IDs, terms of use and citations are in
[`data/README.md`](data/README.md). Software citations and image credits are
in [`ACKNOWLEDGMENTS.md`](ACKNOWLEDGMENTS.md).

### Adapted teaching materials

Several lessons were **adapted** from openly licensed teaching material and
rewritten around the course's Arabidopsis iron-homeostasis datasets. Each
affected notebook starts with an "Adapted from" box that gives the source,
its license and the changes made.

| Source | License | Adapted in |
|---|---|---|
| Harvard Chan Bioinformatics Core (HBC): [Intro-to-DGE](https://hbctraining.github.io/Intro-to-DGE/), [Intro-to-rnaseq-hpc-O2](https://hbctraining.github.io/Intro-to-rnaseq-hpc-O2/), [Intro-to-ChIPseq](https://hbctraining.github.io/Intro-to-ChIPseq/) | CC BY 4.0 | M4L4, M4P1, M4P2, M6P2, M5L1 (STAR section), M7L3 (QC/MACS2 sections) |
| Stephen Turner (UVA), [Count-Based Differential Expression Analysis of RNA-seq Data](https://4va.github.io/biodatasci/r-rnaseq-airway.html), 4-VA JMU 2017 Biological Data Science Workshop ([4va/biodatasci](https://github.com/4va/biodatasci)) | CC BY-NC-SA 4.0 | M4L3 and the `data/airway/` tables. **These are shared under CC BY-NC-SA 4.0** (see [LICENSE](LICENSE), item 9) |
| Ram Basnet, [Bash-Script-Fundamentals](https://github.com/rambasnet/Bash-Script-Fundamentals) | MIT | M1P2 and the Module 1 demo scripts |
| GeoHackWeek conda tutorial; nf-core metro maps; figures from Love et al. 2014 and Jackson et al. 2024 | CC BY 4.0 / MIT | Single images, credited where they appear |

Material adapted from sources with NoDerivatives or no public license was
**left out** (see below). M4L2, which had followed examples from *R for
Data Science* (CC BY-NC-ND 3.0), was rewritten from scratch with new text,
examples and exercises on the GSE79275 data.

## Excluded material

To protect students and future cohorts, and to respect third-party
licenses, these were **not** published:

- answer keys (`*_A.ipynb`, `Development/answers/`), grading files,
  completed exercise scripts (`blast.sh`, `practice2.sh`, the M3E1 R
  script), and all student folders and work;
- M1L1, M0L1, `Module_0/Extra/` and `Data_Sci_R_Practice/` (MU Data
  Science & Analytics material with no public license);
- third-party figures that are not openly licensed or whose source is
  unclear, and screenshots that showed usernames, internal IPs or other
  people's details (see [`ACKNOWLEDGMENTS.md`](ACKNOWLEDGMENTS.md));
- a count table with no public accession (`ExampleRnaSeqRawReads.txt`);
- generated outputs (HOMER/MultiQC/fastp reports, BAM/bigWig files, Salmon
  indexes). A few deepTools figures made from public DAP-seq data are kept
  in [`modules/module_7_dap_seq/figures/`](modules/module_7_dap_seq/figures/README.md);
- saved notebook outputs (removed for privacy), except one toy-data R lab
  (M4L1).

## My role

I designed and wrote the curriculum: all modules, labs, practices and
exercises, the choice of datasets around the Arabidopsis iron-homeostasis
research, the HPC environments, the reusable Salmon/STAR/DAP-seq pipelines,
and the course-operations tooling (weekly module deployment and staged
answer release on a shared cluster file system, in [`tools/`](tools/README.md)).

## Building the site

```bash
pip install "jupyter-book>=1.0,<2"
python tools/check_links.py          # relative links, images, _toc.yml entries
jupyter-book build .                 # notebooks are not executed
```

GitHub Actions ([`.github/workflows/deploy-book.yml`](.github/workflows/deploy-book.yml))
runs the link check, builds the book and deploys it to GitHub Pages on every
push to `main`.

## License

Copyright (c) 2026 Pierce Taylor. **All rights reserved**, except for the
third-party material listed in [LICENSE](LICENSE) and
[ACKNOWLEDGMENTS.md](ACKNOWLEDGMENTS.md), which stays under its original
license. In particular, M4L3 and the `data/airway/` tables are distributed
under [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/)
(legal code in [`LICENSES/CC-BY-NC-SA-4.0.txt`](LICENSES/CC-BY-NC-SA-4.0.txt)).
Datasets and software keep their own terms.
