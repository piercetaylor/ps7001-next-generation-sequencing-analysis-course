# PS4002/PS7001: Next-Generation Sequencing Analysis

A hands-on course in analyzing sequencing data, written by Pierce Taylor for
upper-level undergraduates (PS4002) and graduate students (PS7001) at the
University of Missouri. Students start with no programming background and
finish by running their own RNA-seq or DAP-seq analysis on an HPC cluster.
Most of the work uses public *Arabidopsis* iron-homeostasis and cadmium datasets.

**Read it online:** [piercetaylor.github.io/ps7002-next-generation-sequencing-analysis-course](https://piercetaylor.github.io/ps7002-next-generation-sequencing-analysis-course/)
· **Try the R notebooks:** [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/piercetaylor/ps7002-next-generation-sequencing-analysis-course/main?urlpath=lab/tree/modules/module_4_rnaseq_in_r)

## What's in the course

| Module | Topic |
|---|---|
| [0](modules/module_0_orientation/README.md) | Orientation: computing resources, using AI tools well |
| [1](modules/module_1_bash_hpc/README.md) | Bash, conda and the Hellbender HPC |
| [2](modules/module_2_ngs_preprocessing/README.md) | Sequencing data, file formats, QC and trimming (fastp) |
| [3](modules/module_3_rnaseq_pseudoalignment/README.md) | RNA-seq with Salmon pseudo-alignment |
| [4](modules/module_4_rnaseq_in_r/README.md) | RNA-seq in R: ggplot2, DESeq2, GO/KEGG enrichment |
| [5](modules/module_5_genome_alignment/README.md) | Genome alignment with STAR, viewing reads in IGV |
| [6](modules/module_6_full_rnaseq_workflow/README.md) | A full RNA-seq workflow and study design |
| [7](modules/module_7_dap_seq/README.md) | DAP-seq: peak calling (MACS2), motifs (HOMER/MEME) |
| [8](modules/module_8_capstone/README.md) | Capstone project |

Start with [`modules/start_here.ipynb`](modules/start_here.ipynb). Each module
has its own README with objectives and assignments. Reusable Salmon, STAR and
DAP-seq pipelines are in [`pipelines/`](pipelines/README.md), conda
environments in [`environment/`](environment/README.md), and the scripts I used
to release modules and answers each week in [`tools/`](tools/README.md).

## Running it

The notebooks were written for the Hellbender HPC (SLURM, large FASTQ files),
so most are best read rather than run. The Module 4 R notebooks are the
exception: they run on a laptop or on Binder.

```bash
git clone https://github.com/piercetaylor/ps7002-next-generation-sequencing-analysis-course.git
cd ps7002-next-generation-sequencing-analysis-course
mamba env create -f environment/module_3_rnaseq_salmon.yml
bash data/fetch_data.sh small    # count tables for the R notebooks
```

No sequencing data is stored here. [`data/README.md`](data/README.md) lists
every dataset with its accession and citation, and `fetch_data.sh` downloads them.

## Credits and license

Some lessons build on openly licensed material, mainly the Harvard Chan
Bioinformatics Core training lessons (CC BY 4.0) and Stephen Turner's airway
RNA-seq lesson (CC BY-NC-SA 4.0). Each adapted notebook says so at the top, and
[`ACKNOWLEDGMENTS.md`](ACKNOWLEDGMENTS.md) lists every source, dataset and tool.
Answer keys and student work are not included.

My own material is © 2026 Pierce Taylor, all rights reserved. Third-party
material keeps its own license (see [`LICENSE`](LICENSE)).
