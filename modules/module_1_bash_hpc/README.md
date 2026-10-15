# Module 1: Bash and HPC basics

An introduction to command-line bioinformatics on the Hellbender HPC: navigating Linux, Bash scripting, conda/mamba environments, and running command-line programs (BLAST) from scripts.

## Learning objectives

- Navigate the Linux file system and manage files and directories from the terminal
- Write Bash scripts that use variables, conditionals, loops and functions
- Create, activate and export conda/mamba environments from `.yml` files
- Install and run a bioinformatics program (BLAST+) from a script to retrieve Arabidopsis cDNA sequences

## Assignments

**Overview / start here**

- [Module 1: Introduction to Genomics](module_1_overview.ipynb)

**Labs**

- [M1L2 - Introduction to Bash via Hellbender](lab/M1L2_Introduction_To_Bash_Via_Hellbender.ipynb)

**Practices**

- [M1P1 Creating and Managing Environments](practice/M1P1_Creating_and_Managing_Environments.ipynb)
- [M1P2 - Creation of Bash scripts for automation of system-level tasks](practice/M1P2_Intro_To_Bash_Scripting.ipynb)
- [M1P3 - Use of Programs in Bash](practice/M1P3_Use_of_Programs_In_Bash.ipynb)

**Exercises**

- [Bash Scripting for searching a Database Via Blast](exercise/M1E1_Blast_Bash_Scripting.ipynb)

**Other material**

- [Demo scripts](resources/demo_scripts/README.md)

## Data

`data/examples/` (committed example FASTA and gene lists); Ensembl Plants TAIR10 cDNA and a BLAST database (`data/fetch_data.sh reference blast`).

See [`data/README.md`](../../data/README.md) for accessions and citations.

## Adapted material

| Notebook / section | Source and license | Changes |
|---|---|---|
| M1P2 Intro to Bash Scripting and `resources/demo_scripts/` | [Bash-Script-Fundamentals](https://github.com/rambasnet/Bash-Script-Fundamentals) by Ram Basnet, MIT License (c) 2019 Ram Basnet | Reorganised and rewritten for bioinformatics on the Hellbender HPC; demo scripts kept with the MIT notice |
| Conda diagram in M1P1 | [GeoHackWeek conda tutorial](https://geohackweek.github.io/datasharing/01-conda-tutorial/), CC BY 4.0 | Image reused unchanged with credit |

## Not included in the public version

- M1L1 "Introduction to Jupyter" was adapted from MU Data Science & Analytics program material with no public license, so it is not included.
- The completed `blast.sh` and `practice2.sh` scripts (exercise solutions) are not included. `exercise/blast.sh` is an empty template.
- Demo scripts `menu.sh` (credited upstream to LinuxCommand.org, license unclear), `finalGrade.txt` and `gradebook.sh` are not included.

> **Note:** most notebooks in this module run on an HPC (Hellbender at the University of Missouri, with SLURM) and use large files. Saved outputs were removed for privacy.
