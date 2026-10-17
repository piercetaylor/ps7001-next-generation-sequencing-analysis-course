# Module 8 (optional): Single-cell RNA-seq

An optional lab and practice on single-cell RNA-seq (scRNA-seq) of the *Arabidopsis thaliana* root: how 10x Genomics libraries are built and sequenced, read QC and STARsolo alignment of a public 10x run, and clustering and cell-type annotation in Seurat following Ryu *et al.* (2019). These notebooks are not graded. Students who choose a scRNA-seq dataset for the [final project](../module_8_capstone/module_8_final_project.ipynb) can use them as a starting point.

## Learning objectives

- Explain how droplet-based scRNA-seq assigns reads to cells (cell barcodes) and to molecules (UMIs)
- Describe what each 10x FASTQ (R1, R2, I1) contains, and why R1 is not trimmed or aligned
- Run read QC and STARsolo on a 10x run, and interpret the STARsolo summary
- Filter, normalize, integrate and cluster scRNA-seq data in Seurat v5
- Annotate root cell types with known marker genes and compare the result with the original publication

## Assignments

**Overview / start here**

- [Module 8 - Optional scRNA-Seq Lab and Practice](module_8_Overview_OPTIONAL.ipynb)

**Labs**

- [M8_L1 - Single-Cell RNA-Seq Overview](lab/M8_L1_scRNA_Seq_Overview.ipynb)
- [M8_L2 - scRNA-Seq Data Pre-Processing and QC](lab/M8_L2_scRNA_Seq_Data_Pre_Processing_and_QC.ipynb)

**Practices**

- [M8_P1 - scRNA-Seq Analysis in Seurat](practice/M8_P1_scRNA_Seq_Seurat_Analysis.ipynb)

## Data

GSE123013 (Ryu *et al.* 2019, *Plant Physiol.* 179:1444-1456): 10x Genomics Single Cell 3' v2 libraries of root-tip protoplasts from three wild-type samples and the *rhd6-1* and *gl2* mutants.

- `fetch_data.sh scrna_ryu`: the Cell Ranger count matrices from GEO (~190 MB), for M8_P1
- `fetch_data.sh scrna_fastq`: the first 10 million read pairs of WT_rep2 (SRR8257102) and the 10x v2 barcode whitelist, for M8_L2 (needs the SRA Toolkit)
- `fetch_data.sh reference`: the Ensembl Plants release 62 TAIR10 genome and GTF, for the STAR index in M8_L2

See [`data/README.md`](../../data/README.md) for accessions and citations.

Conda environments: [`module_8_scrna.yml`](../../environment/module_8_scrna.yml) (`module_8_scRNA`: STAR, SRA Toolkit, FastQC, MultiQC, seqkit) for M8_L2, and [`module_8_seurat.yml`](../../environment/module_8_seurat.yml) (`module_8_seurat`: R, Seurat v5) for M8_P1.

## Adapted material

| Notebook / section | Source and license | Changes |
|---|---|---|
| M8_L1 (outline: droplet capture, barcodes and UMIs, experimental design, workflow); M8_P1 (QC-metric reasoning) | [HBC Introduction to single-cell RNA-seq](https://hbctraining.github.io/Intro-to-scRNAseq/) (Piper, Mistry, Liu, Gammerdinger, Khetani 2022, [doi:10.5281/zenodo.5826256](https://doi.org/10.5281/zenodo.5826256); [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)) | Newly written text, applied to the *Arabidopsis* root; no text or figures copied |
| M8_L1, M8_P1 (plant-specific framing, root cell-type markers) | [Galaxy Training Network: Analysis of plant scRNA-Seq Data with Scanpy](https://training.galaxyproject.org/training-material/topics/single-cell/tutorials/scrna-plant/tutorial.html) (Tekman, Serrano-Solano, Gallardo, Videm; [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)) | Different dataset (GSE123013 instead of GSE123818) and toolkit (Seurat instead of Scanpy); text newly written |
| M8_P1 (order of the Seurat workflow and function calls) | Satija Lab Seurat vignettes: [Guided clustering tutorial](https://satijalab.org/seurat/articles/pbmc3k_tutorial) and [Integrative analysis in Seurat v5](https://satijalab.org/seurat/articles/seurat5_integration) (Seurat package: [MIT](https://github.com/satijalab/seurat/blob/master/LICENSE.md)) | Applied to *Arabidopsis* root protoplasts with the parameters of Ryu *et al.* (2019); text and code comments newly written |
| M8_L2 (STARsolo options) | [STARsolo documentation](https://github.com/alexdobin/STAR/blob/master/docs/STARsolo.md) (Alexander Dobin; STAR: MIT) | Cited as a reference; options explained for 10x v2 *Arabidopsis* data |

Analysis parameters (gene and cell filters, 1,000 variable genes, CCA integration, 20 dimensions, clustering resolution 0.2) follow the Materials and Methods of Ryu *et al.* (2019), [doi:10.1104/pp.18.01482](https://doi.org/10.1104/pp.18.01482). No figures from the paper are reproduced.

> **Note:** M8_L2 runs on an HPC (Hellbender at the University of Missouri, with SLURM) and uses large files. M8_P1 needs about 8 GB of RAM. Saved outputs were removed.
