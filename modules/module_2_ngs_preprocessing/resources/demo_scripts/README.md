# Module 2 demo scripts

Original example scripts by Pierce Taylor for project setup and
pre-processing on the HPC.

| Script | Purpose |
|---|---|
| `create_example_project_folder.sh` | Create a standard NGS project layout (`data/`, `references/`, `results/`, `scripts/`, ...) |
| `fetchSRA.sh` | Download a list of SRA runs with the SRA Toolkit |
| `SRANameChange.sh` | Rename downloaded `SRR*.fastq.gz` files to sample names (GSE79275 root samples) |
| `FastQCTrimmomaticFastQC.sh` | FastQC, then Trimmomatic, then FastQC again on paired-end reads |
| `SAMExampleBuilderForIGV.sh` | Build a tiny SAM/BAM example for viewing in IGV |

Paths in these scripts are relative or come from variables. Set them for
your own system before you run the scripts.
