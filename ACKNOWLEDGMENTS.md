# Acknowledgments, attributions and citations

The course materials are original work by Pierce Taylor (see
[LICENSE](LICENSE)), except for the third-party material listed below. That
material is **not** covered by the "all rights reserved" notice and stays
under its own license.

## Adapted teaching materials

| Where in this repository | Original source | Authors / organization | License (checked at the source) | What was changed |
|---|---|---|---|---|
| `module_4_rnaseq_in_r/lab/M4L4_RNA_Seq_Review.ipynb` | [Introduction to DGE](https://hbctraining.github.io/Intro-to-DGE/) ([hbctraining/Intro-to-DGE](https://github.com/hbctraining/Intro-to-DGE)): "Experimental planning considerations" and the workflow overview | Harvard Chan Bioinformatics Core (HBC) training team | [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) (statement in the repository README) | Shortened and rewritten. Example data changed to the Arabidopsis iron-homeostasis series GSE79275; pipeline described as fastp + Salmon on the Hellbender HPC; third-party figures removed |
| `module_4_rnaseq_in_r/lab/M4L3_Graphing_RNA_Seq_Results.ipynb`, its figure `lab/images/M4L3_Graphing_RNA_Seq_Results_28fd7d8a.png`, and `data/airway/` (`airway_scaledcounts.csv`, `airway_metadata.csv`; `annotables_grch38.csv` is downloaded) | [Count-Based Differential Expression Analysis of RNA-seq Data](https://4va.github.io/biodatasci/r-rnaseq-airway.html), 4-VA JMU 2017 Biological Data Science Workshop ([4va/biodatasci](https://github.com/4va/biodatasci)); the CSV files and `countdatacoldata.png` from the same repository | Stephen Turner, University of Virginia (workshop instructor and main author of the repository) | [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/) (LICENSE file in the repository and the footer of every lesson page). **This notebook and its data files are shared under CC BY-NC-SA 4.0, not under the all-rights-reserved notice** (see [LICENSE](LICENSE), item 9, and [`LICENSES/CC-BY-NC-SA-4.0.txt`](LICENSES/CC-BY-NC-SA-4.0.txt)) | Reduced to the import, DESeq2 and plotting sections; background, "poor man's DGE", pathway and homework sections and the exercises left out; MA and volcano exercises turned into worked `ggplot2` code with line-by-line notes; heat map redone with `pheatmap` (top 50 genes, annotations); paths changed to `data/airway/`; a folder screenshot removed. CSV files and figure unchanged. `annotables_grch38.csv` comes from Stephen Turner's [annotables](https://github.com/stephenturner/annotables) package (GPL-3, Ensembl data) |
| `module_4_rnaseq_in_r/practice/M4P1_Intro_to_DE_Analysis.ipynb` | Introduction to DGE: DESeq2 lessons (count normalization, sample QC, DE analysis, Wald test) | HBC | CC BY 4.0 | HBC's Mov10 example data replaced with the GSE79275 count matrix (opt3-2/Col-0, with and without Cd); code adapted; questions added; third-party figures removed |
| `module_4_rnaseq_in_r/practice/M4P2_Functional_Analysis.ipynb` | Introduction to DGE: functional analysis lessons (over-representation analysis, functional class scoring/GSEA) | HBC | CC BY 4.0 | Rewritten for Arabidopsis (TAIR IDs, `org.At.tair.db`, KEGG `ath`) using GSE79275; GO-hierarchy and GSEA figures from journals removed |
| `module_6_full_rnaseq_workflow/practice/M6P2_Interactions_and_Study_Design_for_DESeq2.ipynb` | Introduction to DGE: "Wald test results" and design-formula material | HBC | CC BY 4.0 | Applied to the GSE79275 genotype x treatment design with interaction terms |
| `module_5_genome_alignment/lab/M5L1_Genome_Alignments_and_File_Formats.ipynb` (section "How does STAR work?") | [Introduction to RNA-seq using HPC](https://hbctraining.github.io/Intro-to-rnaseq-hpc-O2/) ([hbctraining/Intro-to-rnaseq-hpc-O2](https://github.com/hbctraining/Intro-to-rnaseq-hpc-O2)): STAR alignment lesson and the `alignment_STAR_step1-5` figures (byte-identical to the HBC files) | HBC | CC BY 4.0 | Light edits; applied to Arabidopsis TAIR10 instead of human |
| `module_7_dap_seq/lab/M7L3_DAP_Seq_Analysis_Pipeline.ipynb` (QC and peak-calling sections; `narrowPeak` figure) | [Introduction to ChIP-seq using HPC](https://hbctraining.github.io/Intro-to-ChIPseq/) ([hbctraining/Intro-to-ChIPseq](https://github.com/hbctraining/Intro-to-ChIPseq)): FastQC, MACS2 and narrowPeak lessons | HBC | CC BY 4.0 | Rewritten for DAP-seq of Arabidopsis ARF transcription factors with a beads-only control (GSE60141) |
| `module_1_bash_hpc/practice/M1P2_Intro_To_Bash_Scripting.ipynb` and `module_1_bash_hpc/resources/demo_scripts/` | [Bash-Script-Fundamentals](https://github.com/rambasnet/Bash-Script-Fundamentals) | Ram Basnet | [MIT](https://github.com/rambasnet/Bash-Script-Fundamentals/blob/main/LICENSE), Copyright (c) 2019 Ram Basnet (license copy kept next to the scripts) | Notebook reorganised and rewritten for bioinformatics on the HPC; demo scripts unchanged (three files left out) |
| `module_1_bash_hpc/resources/images/conda-env2-GeoHackWeek.png` (used in M1P1) | [GeoHackWeek: Conda tutorial](https://geohackweek.github.io/datasharing/01-conda-tutorial/) ([geohackweek/datasharing](https://github.com/geohackweek/datasharing)) | GeoHackWeek contributors | CC BY 4.0 (LICENSE.md in the source repository) | Unchanged; credited in the notebook |
| nf-core metro-map images in M6L2, M6P1, M7P1 | [nf-core/rnaseq](https://github.com/nf-core/rnaseq), [nf-core/chipseq](https://github.com/nf-core/chipseq) | nf-core community | MIT | Unchanged; credited under each image |
| Figure in M5L1 (alignment strategies) | Jackson DJ, Cerveau N, Posnien N. *Front. Zool.* 2024;21:17, Fig. 2, [doi:10.1186/s12983-024-00538-y](https://doi.org/10.1186/s12983-024-00538-y) | the authors | CC BY 4.0 (publisher page) | Unchanged; credited |
| Shrunken-LFC and rlog figures in M4P1 | Love MI, Huber W, Anders S. *Genome Biol.* 2014;15:550, [doi:10.1186/s13059-014-0550-8](https://doi.org/10.1186/s13059-014-0550-8), and the DESeq2 documentation, as reproduced in the HBC lessons | the authors / HBC | CC BY 4.0 | Unchanged; credited |

### Flagged and not published

These items were adapted from sources whose license does not allow
publishing them as they are, or whose source could not be identified. They
are **not** in this repository.

| Item in the live course | Source | Problem |
|---|---|---|
| M1L1 "Introduction to Jupyter" and its `JH_*` screenshots; M0L1 "Jupyter tips" and its GIFs; `Module_0/Extra/` (Git, JupyterHub); `Module_4/Resources/Data_Sci_R_Practice/` | MU Data Science & Analytics graduate program course material | No public license; the screenshots also show other people's names and usernames |
| `menu.sh` demo script | LinuxCommand.org (William Shotts), via Bash-Script-Fundamentals | Original license unclear |
| M3L1 expectation-maximization walkthrough | Appears to follow teaching material by Alexander Lachmann | **Source to be confirmed.** The figures were removed; the text and toy code remain with a note |

### Resolved since the first release

- **M4L3** is now published under CC BY-NC-SA 4.0 as an exception to the
  all-rights-reserved notice (see the table above). `sigresults.csv` from
  the live course is an output of the notebook, so it is regenerated rather
  than committed.
- **M4L2 "Graph creation in R"** followed the `mpg` walkthrough of
  *R for Data Science*, 1st ed. (CC BY-NC-ND 3.0 US) and copied some of its
  sentences. It was **rewritten from scratch** by Pierce Taylor: new text,
  new examples built on the GSE79275 iron-homeostasis counts, and new
  exercises. It is no longer an adaptation, so it has no "Adapted from" box
  and is covered by the repository notice. A check of the new notebook's
  text found no shared 8-word sequences with the old notebook or with the
  R4DS chapter, apart from URLs. The notebook points to R4DS and to
  Wickham's *ggplot2* book under "Further reading".

## Third-party figures removed

All 175 embedded notebook images and 32 image files were checked one by one. Removed images were
replaced with a short italic note giving the reason and, where known, a
citation:

- figures from journal articles that are not openly licensed (O'Malley et al.
  2016 *Cell*; Bartlett et al. 2017 *Nat Protoc*; Subramanian et al. 2005
  *PNAS*; Liu et al. 2014 *Bioinformatics*; a *Nature Reviews* GO figure);
- vendor and education-website figures (Illumina, Biology Online, ChIP-seq and
  ATAC-seq overviews), annotated IGV tutorial slides, and Globus documentation
  screenshots;
- figures whose original source could not be confirmed;
- screenshots that showed cluster usernames, internal IP addresses, or a
  third party's name and email. One screenshot (`M2L2HellbenderDesktopConfig.jpg`)
  was kept with the username blacked out.

The remaining screenshots are the author's own (Jupyter, IGV, MultiQC,
RStudio, NCBI GEO record pages) or are credited above.

## Datasets

Full citations, accessions and terms are in [`data/README.md`](data/README.md).
In short:

- **GSE79275**: Khan MA, et al. *Plant Cell Environ.* 2018;41(10):2263-2276. [doi:10.1111/pce.13192](https://doi.org/10.1111/pce.13192)
- **GSE128156 / GSE128157**: McInturf SA, et al. *J Exp Bot.* 2022;73(1):324-338. [doi:10.1093/jxb/erab393](https://doi.org/10.1093/jxb/erab393)
- **GSE60143 / GSE60141 (DAP-seq)**: O'Malley RC, et al. *Cell.* 2016;165(5):1280-1292. [doi:10.1016/j.cell.2016.04.038](https://doi.org/10.1016/j.cell.2016.04.038); protocol: Bartlett A, et al. *Nat Protoc.* 2017;12(8):1659-1672. [doi:10.1038/nprot.2017.055](https://doi.org/10.1038/nprot.2017.055)
- **GSE72548**: Shanks CM, et al. *Mol Plant Microbe Interact.* 2016;29(1):57-68. [doi:10.1094/MPMI-07-15-0156-R](https://doi.org/10.1094/MPMI-07-15-0156-R)
- **SRR1971253**: Tan EH, et al. *eLife.* 2015;4:e06516. [doi:10.7554/eLife.06516](https://doi.org/10.7554/eLife.06516) (citation to be confirmed)
- **GSE52778 / airway**: Himes BE, et al. *PLoS One.* 2014;9(6):e99625. [doi:10.1371/journal.pone.0099625](https://doi.org/10.1371/journal.pone.0099625); Love M. *airway* Bioconductor package, [doi:10.18129/B9.bioc.airway](https://doi.org/10.18129/B9.bioc.airway)
- **Ensembl Plants (release 62)**: Yates AD, et al. *Nucleic Acids Res.* 2022;50(D1):D996-D1003. [doi:10.1093/nar/gkab1007](https://doi.org/10.1093/nar/gkab1007)
- **TAIR10**: Lamesch P, et al. *Nucleic Acids Res.* 2012;40:D1202-D1210. [doi:10.1093/nar/gkr1090](https://doi.org/10.1093/nar/gkr1090)
- **SRA**: Leinonen R, Sugawara H, Shumway M. The Sequence Read Archive. *Nucleic Acids Res.* 2011;39:D19-D21. [doi:10.1093/nar/gkq1019](https://doi.org/10.1093/nar/gkq1019)

## Software taught in the course

| Tool | Citation |
|---|---|
| fastp | Chen S, Zhou Y, Chen Y, Gu J. fastp: an ultra-fast all-in-one FASTQ preprocessor. *Bioinformatics.* 2018;34(17):i884-i890. [doi:10.1093/bioinformatics/bty560](https://doi.org/10.1093/bioinformatics/bty560) |
| FastQC | Andrews S. FastQC: a quality control tool for high throughput sequence data. Babraham Bioinformatics. [Software](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) |
| MultiQC | Ewels P, Magnusson M, Lundin S, Kaller M. MultiQC: summarize analysis results for multiple tools and samples in a single report. *Bioinformatics.* 2016;32(19):3047-3048. [doi:10.1093/bioinformatics/btw354](https://doi.org/10.1093/bioinformatics/btw354) |
| Salmon | Patro R, Duggal G, Love MI, Irizarry RA, Kingsford C. Salmon provides fast and bias-aware quantification of transcript expression. *Nat Methods.* 2017;14(4):417-419. [doi:10.1038/nmeth.4197](https://doi.org/10.1038/nmeth.4197) |
| STAR | Dobin A, Davis CA, Schlesinger F, et al. STAR: ultrafast universal RNA-seq aligner. *Bioinformatics.* 2013;29(1):15-21. [doi:10.1093/bioinformatics/bts635](https://doi.org/10.1093/bioinformatics/bts635) |
| DESeq2 | Love MI, Huber W, Anders S. Moderated estimation of fold change and dispersion for RNA-seq data with DESeq2. *Genome Biol.* 2014;15(12):550. [doi:10.1186/s13059-014-0550-8](https://doi.org/10.1186/s13059-014-0550-8) |
| tximport | Soneson C, Love MI, Robinson MD. Differential analyses for RNA-seq: transcript-level estimates improve gene-level inferences. *F1000Res.* 2015;4:1521. [doi:10.12688/f1000research.7563.2](https://doi.org/10.12688/f1000research.7563.2) |
| clusterProfiler | Wu T, Hu E, Xu S, et al. clusterProfiler 4.0: a universal enrichment tool for interpreting omics data. *Innovation (Camb).* 2021;2(3):100141. [doi:10.1016/j.xinn.2021.100141](https://doi.org/10.1016/j.xinn.2021.100141) |
| GSEA (method) | Subramanian A, Tamayo P, Mootha VK, et al. Gene set enrichment analysis. *PNAS.* 2005;102(43):15545-15550. [doi:10.1073/pnas.0506580102](https://doi.org/10.1073/pnas.0506580102) |
| Bowtie2 | Langmead B, Salzberg SL. Fast gapped-read alignment with Bowtie 2. *Nat Methods.* 2012;9(4):357-359. [doi:10.1038/nmeth.1923](https://doi.org/10.1038/nmeth.1923) |
| SAMtools | Li H, Handsaker B, Wysoker A, et al. The Sequence Alignment/Map format and SAMtools. *Bioinformatics.* 2009;25(16):2078-2079. [doi:10.1093/bioinformatics/btp352](https://doi.org/10.1093/bioinformatics/btp352) |
| BEDTools | Quinlan AR, Hall IM. BEDTools: a flexible suite of utilities for comparing genomic features. *Bioinformatics.* 2010;26(6):841-842. [doi:10.1093/bioinformatics/btq033](https://doi.org/10.1093/bioinformatics/btq033) |
| MACS2 | Zhang Y, Liu T, Meyer CA, et al. Model-based analysis of ChIP-Seq (MACS). *Genome Biol.* 2008;9(9):R137. [doi:10.1186/gb-2008-9-9-r137](https://doi.org/10.1186/gb-2008-9-9-r137) |
| HOMER | Heinz S, Benner C, Spann N, et al. Simple combinations of lineage-determining transcription factors prime cis-regulatory elements required for macrophage and B cell identities. *Mol Cell.* 2010;38(4):576-589. [doi:10.1016/j.molcel.2010.05.004](https://doi.org/10.1016/j.molcel.2010.05.004) |
| MEME Suite | Bailey TL, Johnson J, Grant CE, Noble WS. The MEME Suite. *Nucleic Acids Res.* 2015;43(W1):W39-W49. [doi:10.1093/nar/gkv416](https://doi.org/10.1093/nar/gkv416) |
| deepTools | Ramirez F, Ryan DP, Gruning B, et al. deepTools2: a next generation web server for deep-sequencing data analysis. *Nucleic Acids Res.* 2016;44(W1):W160-W165. [doi:10.1093/nar/gkw257](https://doi.org/10.1093/nar/gkw257) |
| IGV | Robinson JT, Thorvaldsdottir H, Winckler W, et al. Integrative genomics viewer. *Nat Biotechnol.* 2011;29(1):24-26. [doi:10.1038/nbt.1754](https://doi.org/10.1038/nbt.1754) |
| BLAST+ | Camacho C, Coulouris G, Avagyan V, et al. BLAST+: architecture and applications. *BMC Bioinformatics.* 2009;10:421. [doi:10.1186/1471-2105-10-421](https://doi.org/10.1186/1471-2105-10-421) |
| SRA Toolkit | NCBI SRA Toolkit, [github.com/ncbi/sra-tools](https://github.com/ncbi/sra-tools); see Leinonen et al. 2011 above |
| Picard | Broad Institute. Picard Toolkit. [broadinstitute.github.io/picard](https://broadinstitute.github.io/picard/) |
| R / Bioconductor / ggplot2 | R Core Team. *R: A language and environment for statistical computing.* R Foundation for Statistical Computing; Wickham H. *ggplot2: Elegant Graphics for Data Analysis.* Springer; [bioconductor.org](https://bioconductor.org) |
| Jupyter, conda/mamba, nf-core | [jupyter.org](https://jupyter.org), [conda.io](https://docs.conda.io), [nf-co.re](https://nf-co.re) |

Article citations were checked against PubMed.

## Other credits

- The course ran on the **Hellbender** HPC cluster operated by Research
  Support Solutions (RSS), University of Missouri. Hellbender details in
  the notebooks come from the public
  [RSS documentation](https://docs.itrss.umsystem.edu/pub/hpc/hellbender).
- The Arabidopsis iron-homeostasis and cadmium datasets come from the
  Mendoza-Cozatl laboratory (University of Missouri), published as cited
  above.
- Some notebooks (for example M0L2 "Prompting for Success") include
  AI-generated responses as teaching examples, and the pipeline scripts were
  drafted with help from generative AI (see
  [`pipelines/README.md`](pipelines/README.md)).
