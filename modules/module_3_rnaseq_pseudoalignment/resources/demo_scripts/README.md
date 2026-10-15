# Module 3 demo scripts

| Script | Purpose |
|---|---|
| `salmon.sh` | Build a Salmon index from the TAIR10 representative cDNA set and quantify the six GSE79275 root samples (`--geneMap` produces gene-level `quant.genes.sf`) |
| `MakeModule3BashKernel.sh` | Register a Jupyter Bash kernel that activates the `Module_3_Local_Env` environment ([`environment/module_3_rnaseq_salmon.yml`](../../../../environment/module_3_rnaseq_salmon.yml)) |

Both scripts expect to be run from the `m3_project_pseudo_alignment/` project
folder created in M2E1/M3L2. Inputs are described in
[`data/README.md`](../../../../data/README.md).
