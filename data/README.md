# Data

The course uses only **public** sequencing data and reference files. Raw and
large files are **not committed** to this repository. They are downloaded
by [`fetch_data.sh`](fetch_data.sh) into subfolders of `data/`, and those
subfolders are git-ignored:

```bash
bash data/fetch_data.sh small      # GEO count tables, the M4L3 airway annotation table, and a check of the committed examples (~20 MB)
bash data/fetch_data.sh reference  # Ensembl Plants release 62 TAIR10 genome/cDNA/GTF/GFF3 plus TAIR10 blast sets
bash data/fetch_data.sh practice   # small practice files for Module 2
bash data/fetch_data.sh opt3 cd    # GSE79275 / GSE128156 root RNA-seq FASTQs (HPC only, about 12 GB)
bash data/fetch_data.sh dapseq     # GSE60141 DAP-seq FASTQs (HPC only)
bash data/fetch_data.sh scrna_ryu  # GSE123013 scRNA-seq Cell Ranger matrices (Module 8 optional, ~190 MB)
bash data/fetch_data.sh scrna_fastq  # 10M-spot subset of GSE123013 WT_rep2 + 10x v2 whitelist (HPC only, needs sra-tools)
bash data/fetch_data.sh all        # everything except the two scrna targets
```

Notebooks find this folder through the `DATA_DIR` variable. It defaults to
`../../../data` relative to each notebook, which is this folder. Set
`DATA_DIR` yourself if you keep the data somewhere else.

| Folder (created by the script) | Contents |
|---|---|
| `geo/` | GEO processed files (count tables, series matrix, narrowPeak) |
| `reference/ensembl_plants_62/` | TAIR10 genome, cDNA, GTF and GFF3 from Ensembl Plants release 62 |
| `reference/tair10/` | TAIR10 blast sets and GFF3 from TAIR (used in M3P2/M3E1) |
| `blast/` | BLAST database built from the TAIR10 cDNA (Module 1) |
| `practice/` | Small files for M2P2 and M2P3, made from public runs |
| `fastq/`, `dapseq/` | Raw FASTQ files (large, HPC only) |
| `scrna/` | Module 8 (optional) single-cell data: GEO Cell Ranger matrices (`GSE123013/`), the WT_rep2 FASTQ subset (`fastq/`) and the 10x barcode whitelist (`whitelist/`) |
| `examples/` | **Committed**: small files, listed with their provenance below |
| `airway/` | Partly **committed**: CSV tables for M4L3 under CC BY-NC-SA 4.0 (see "Airway tables for M4L3" below) |

## Datasets

| Dataset | Organism | Assay | Used in | License / terms | Original publication | Citation status |
|---|---|---|---|---|---|---|
| [GSE79275](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE79275) (SRA [SRP071838](https://www.ncbi.nlm.nih.gov/sra?term=SRP071838), BioProject [PRJNA315374](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA315374)). The course uses roots of Col-0 (CRN1-1, CRN2-1, CRN3-1 = [SRR3229095](https://www.ebi.ac.uk/ena/browser/view/SRR3229095), [SRR3229098](https://www.ebi.ac.uk/ena/browser/view/SRR3229098), [SRR3229101](https://www.ebi.ac.uk/ena/browser/view/SRR3229101)) and opt3-2 (ORN1-1, ORN2-1, ORN3-1 = [SRR3229113](https://www.ebi.ac.uk/ena/browser/view/SRR3229113), [SRR3229116](https://www.ebi.ac.uk/ena/browser/view/SRR3229116), [SRR3229119](https://www.ebi.ac.uk/ena/browser/view/SRR3229119)), and the supplementary file `GSE79275_raw_read_counts.txt.gz` | *Arabidopsis thaliana* | RNA-seq (Illumina GA II, 100 bp single-end) | Modules 2, 3, 4, 5, 6 | NCBI GEO/SRA [data usage policies](https://www.ncbi.nlm.nih.gov/home/about/policies/) (public, no restrictions on use) | Khan MA, Castro-Guerrero NA, McInturf SA, Nguyen NT, Dame AN, Wang J, Bindbeutel RK, Joshi T, Jurisson SS, Nusinow DA, Mendoza-Cozatl DG. Changes in iron availability in *Arabidopsis* are rapidly sensed in the leaf vasculature and impaired sensing leads to opposite transcriptional programs in leaves and roots. *Plant Cell Environ.* 2018;41(10):2263-2276. [doi:10.1111/pce.13192](https://doi.org/10.1111/pce.13192). PMID [29520929](https://pubmed.ncbi.nlm.nih.gov/29520929/) | Verified (GEO record + PubMed) |
| [GSE128156](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE128156) (SRA [SRP188181](https://www.ncbi.nlm.nih.gov/sra?term=SRP188181)). Cd-treated (72 h) roots: CRT1-1, CRT2-1, CRT3-1 = [SRR8713301](https://www.ebi.ac.uk/ena/browser/view/SRR8713301), [SRR8713304](https://www.ebi.ac.uk/ena/browser/view/SRR8713304), [SRR8713307](https://www.ebi.ac.uk/ena/browser/view/SRR8713307); ORT1-1, ORT2-1, ORT3-1 = [SRR8713319](https://www.ebi.ac.uk/ena/browser/view/SRR8713319), [SRR8713322](https://www.ebi.ac.uk/ena/browser/view/SRR8713322), [SRR8713325](https://www.ebi.ac.uk/ena/browser/view/SRR8713325) | *A. thaliana* | RNA-seq | Modules 2, 5 | NCBI GEO/SRA policies | McInturf SA, Khan MA, Gokul A, Castro-Guerrero NA, Hohner R, Li J, Marjault HB, Fichman Y, Kunz HH, Goggin FL, Keyster M, Nechushtai R, Mittler R, Mendoza-Cozatl DG. Cadmium interference with iron sensing reveals transcriptional programs sensitive and insensitive to reactive oxygen species. *J Exp Bot.* 2022;73(1):324-338. [doi:10.1093/jxb/erab393](https://doi.org/10.1093/jxb/erab393). PMID [34499172](https://pubmed.ncbi.nlm.nih.gov/34499172/) | Verified (PubMed). GEO lists no PubMed ID for this series; the link rests on the identical title and the GEO contributors |
| [GSE128157](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE128157) (SuperSeries of GSE79275 + GSE128156) | *A. thaliana* | RNA-seq | Modules 2, 3, 5 | NCBI GEO/SRA policies | Cite both publications above | Verified |
| [GSE60143](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE60143) / DAP-seq SubSeries [GSE60141](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE60141) (SRA [SRP045296](https://www.ncbi.nlm.nih.gov/sra?term=SRP045296)). Runs: beads control GSM1924998 = [SRR2926068](https://www.ebi.ac.uk/ena/browser/view/SRR2926068); ARF5/MP GSM1925826 = [SRR2926896](https://www.ebi.ac.uk/ena/browser/view/SRR2926896), GSM1925827 = [SRR2926897](https://www.ebi.ac.uk/ena/browser/view/SRR2926897); ARF2 GSM1925138 = [SRR2926208](https://www.ebi.ac.uk/ena/browser/view/SRR2926208); ARF16 GSM1925137 = [SRR2926207](https://www.ebi.ac.uk/ena/browser/view/SRR2926207); processed `GSE60141_DAPSeq-ARF_ecoli-MP_col-chr1-5_GEM_events.narrowPeak.gz`. Also browsable in the [Plant Cistrome Database](http://neomorph.salk.edu/PlantCistromeDB) | *A. thaliana* | DAP-seq | Module 7, `pipelines/dap_seq` | NCBI GEO/SRA policies | O'Malley RC, Huang SC, Song L, Lewsey MG, Bartlett A, Nery JR, Galli M, Gallavotti A, Ecker JR. Cistrome and epicistrome features shape the regulatory DNA landscape. *Cell.* 2016;165(5):1280-1292. [doi:10.1016/j.cell.2016.04.038](https://doi.org/10.1016/j.cell.2016.04.038). PMID [27203113](https://pubmed.ncbi.nlm.nih.gov/27203113/). Protocol: Bartlett A, O'Malley RC, Huang SC, Galli M, Nery JR, Gallavotti A, Ecker JR. Mapping genome-wide transcription-factor binding sites using DAP-seq. *Nat Protoc.* 2017;12(8):1659-1672. [doi:10.1038/nprot.2017.055](https://doi.org/10.1038/nprot.2017.055) | Verified (GEO record + PubMed) |
| [GSE72548](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE72548) (SRA [SRP063017](https://www.ncbi.nlm.nih.gov/sra?term=SRP063017); runs SRR2221833-SRR2221856) | *A. thaliana* (with *Heterodera schachtii*) | RNA-seq | Module 6 (M6P1, M6E1) | NCBI GEO/SRA policies | Shanks CM, Rice JH, Zubo Y, Schaller GE, Hewezi T, Kieber JJ. The role of cytokinin during infection of *Arabidopsis thaliana* by the cyst nematode *Heterodera schachtii*. *Mol Plant Microbe Interact.* 2016;29(1):57-68. [doi:10.1094/MPMI-07-15-0156-R](https://doi.org/10.1094/MPMI-07-15-0156-R). PMID [26479273](https://pubmed.ncbi.nlm.nih.gov/26479273/) | Verified (GEO record + PubMed) |
| [SRR1971253](https://www.ebi.ac.uk/ena/browser/view/SRR1971253) (BioProject [PRJNA269994](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA269994)); the first 250 reads are used as `small_SRR1971253.fastq` | *A. thaliana* | Whole-genome DNA-seq | Module 2 (M2P2) | NCBI SRA / ENA policies | Tan EH, Henry IM, Ravi M, Bradnam KR, Mandakova T, Marimuthu MP, Korf I, Lysak MA, Comai L, Chan SW. Catastrophic chromosomal restructuring during genome elimination in plants. *eLife.* 2015;4:e06516. [doi:10.7554/eLife.06516](https://doi.org/10.7554/eLife.06516). PMID [25977984](https://pubmed.ncbi.nlm.nih.gov/25977984/) | **Citation to be confirmed.** The BioProject title ("Chromothripsis during genome elimination in plants", UC Davis) matches this paper, but the BioProject does not list the publication |
| Airway: [GSE52778](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE52778) runs SRR1039508, SRR1039509, SRR1039512, SRR1039513, SRR1039516, SRR1039517, SRR1039520, SRR1039521, and the Bioconductor data package [`airway`](https://bioconductor.org/packages/airway/) | *Homo sapiens* (airway smooth muscle cell lines) | RNA-seq | Module 4 lab M4L3, through the processed tables in `data/airway/` (below) | GEO/SRA policies; `airway` package: LGPL; the `data/airway/` tables: CC BY-NC-SA 4.0 | Himes BE, Jiang X, Wagner P, Hu R, Wang Q, Klanderman B, Whitaker RM, Duan Q, Lasky-Su J, Nikolos C, Jester W, Johnson M, Panettieri RA Jr, Tantisira KG, Weiss ST, Lu Q. RNA-Seq transcriptome profiling identifies CRISPLD2 as a glucocorticoid responsive gene that modulates cytokine function in airway smooth muscle cells. *PLoS One.* 2014;9(6):e99625. [doi:10.1371/journal.pone.0099625](https://doi.org/10.1371/journal.pone.0099625). PMID [24926665](https://pubmed.ncbi.nlm.nih.gov/24926665/) | Verified (PubMed; Bioconductor page). Package: Love M. *airway: RangedSummarizedExperiment for RNA-Seq in airway smooth muscle cells, by Himes et al PLoS One 2014*. R package version 1.32.0, [doi:10.18129/B9.bioc.airway](https://doi.org/10.18129/B9.bioc.airway) |
| [GSE123013](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE123013) (SRA [SRP171040](https://www.ncbi.nlm.nih.gov/sra?term=SRP171040)). Root-tip protoplasts, 10x Genomics Single Cell 3' v2, HiSeq 4000: WT_rep1 GSM3490689 = SRR8257100 + SRR8257101; WT_rep2 GSM3490690 = [SRR8257102](https://www.ncbi.nlm.nih.gov/sra/?term=SRR8257102); WT_rep3 GSM3490691 = SRR8257103; *rhd6-1* GSM3490692 = SRR8257104 + SRR8257105; *gl2* GSM3490693 = SRR8257106. The course uses the supplementary file `GSE123013_RAW_matrices.tar.gz` (Cell Ranger 2.1.1 filtered matrices) and the first 10 million spots of SRR8257102 (downloaded from SRA with `fastq-dump`; the ENA copies lack the barcode read) | *A. thaliana* | scRNA-seq (10x Genomics) | Module 8 (optional: M8_L2, M8_P1) | NCBI GEO/SRA policies | Ryu KH, Huang L, Kang HM, Schiefelbein J. Single-cell RNA sequencing resolves molecular relationships among individual plant cells. *Plant Physiol.* 2019;179(4):1444-1456. [doi:10.1104/pp.18.01482](https://doi.org/10.1104/pp.18.01482). PMID [30718350](https://pubmed.ncbi.nlm.nih.gov/30718350/) | Verified (GEO record + PubMed; cell counts per sample match the paper's 7,522 wild-type cells) |
| [Ensembl Plants release 62](https://ftp.ebi.ac.uk/ensemblgenomes/pub/plants/release-62/), *Arabidopsis thaliana* TAIR10: `dna.toplevel`, `cdna.all`, `TAIR10.62.gtf`, `TAIR10.62.gff3` | *A. thaliana* | Reference genome / annotation | Modules 1, 2, 5, 6, 7, 8 (optional), pipelines | [Ensembl data policy](https://www.ensembl.org/info/about/legal/disclaimer.html) (no restrictions on use) | Yates AD, Allen J, Amode RM, et al. Ensembl Genomes 2022: an expanding genome resource for non-vertebrates. *Nucleic Acids Res.* 2022;50(D1):D996-D1003. [doi:10.1093/nar/gkab1007](https://doi.org/10.1093/nar/gkab1007); and TAIR10 (below) | Verified (PubMed) |
| TAIR10 genome release from [TAIR](https://www.arabidopsis.org/) (Download > Genes > TAIR10_genome_release): `TAIR10_cdna_20110103_representative_gene_model_updated`, `TAIR10_GFF3_genes.gff`, `TAIR10_Model_cDNA_associations` | *A. thaliana* | Reference transcriptome / annotation | Module 3 (Salmon index, tx2gene) | TAIR terms of use (see [arabidopsis.org](https://www.arabidopsis.org/)); some TAIR downloads need a subscription | Lamesch P, Berardini TZ, Li D, et al. The Arabidopsis Information Resource (TAIR): improved gene annotation and new tools. *Nucleic Acids Res.* 2012;40(Database issue):D1202-D1210. [doi:10.1093/nar/gkr1090](https://doi.org/10.1093/nar/gkr1090) | Verified (PubMed); check the current TAIR terms before redistributing |
| 10x Genomics barcode whitelist `737K-august-2016.txt` (Single Cell 3' v2), from [10XGenomics/supernova](https://github.com/10XGenomics/supernova/tree/master/tenkit/lib/python/tenkit/barcodes) | - | Barcode list | Module 8 (optional: M8_L2) | Published by 10x Genomics in its public source repository; downloaded by `fetch_data.sh scrna_fastq`, not committed | Zheng GXY, Terry JM, Belgrader P, et al. Massively parallel digital transcriptional profiling of single cells. *Nat Commun.* 2017;8:14049. [doi:10.1038/ncomms14049](https://doi.org/10.1038/ncomms14049) | Verified (file in the 10x repository) |
| Module 1 BLAST database (`tair10_db`) | *A. thaliana* | Built locally with `makeblastdb` from the Ensembl Plants TAIR10 cDNA | Module 1 (M1P3, M1E1) | As for Ensembl Plants | As for Ensembl Plants / TAIR10 | Verified |

### Committed example files (`data/examples/`)

| File | Size | Provenance |
|---|---|---|
| `ExampleFasta.txt` | 6.6 KB | Three transcripts (AT1G76820.1, ATMG00060.1, AT4G16360.1) copied unchanged from the Ensembl Plants TAIR10 cDNA FASTA (`Arabidopsis_thaliana.TAIR10.cdna.all.fa`) |
| `ATOPT3.fa` | 3 KB | The *OPT3* (AT4G16370) locus, NCBI RefSeq [NC_003075.7](https://www.ncbi.nlm.nih.gov/nuccore/NC_003075.7) complement(9247302..9250343), exported from NCBI Nucleotide |
| `Potential_Iron_Homeostasis_Genes_Arabidopsis.txt` | 0.6 KB | A list of TAIR transcript IDs chosen by the author for the Module 1 exercise (no sequence data) |
| `Common_Genes_Arabidopsis.txt` | 0.1 KB | A list of TAIR transcript IDs chosen by the author for M1P3 (no sequence data) |

### Airway tables for M4L3 (`data/airway/`)

These files are **not** covered by the repository's all-rights-reserved
notice. They are third-party files distributed under their own licenses
(see also [`LICENSE`](../LICENSE) and `data/airway/NOTICE.txt`).

| File | Size | Committed? | Source | License | Citation |
|---|---|---|---|---|---|
| `airway_scaledcounts.csv` | 2.1 MB | Yes (byte-identical to the source) | [4va/biodatasci `data/`](https://github.com/4va/biodatasci/tree/master/data), 4-VA JMU 2017 Biological Data Science Workshop, Stephen Turner (UVA). Length-scaled kallisto counts for the 8 GSE52778 runs | [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/) (repository LICENSE) | Turner S. *Count-Based Differential Expression Analysis of RNA-seq Data*, [4va.github.io/biodatasci](https://4va.github.io/biodatasci/r-rnaseq-airway.html); data from Himes et al. 2014 (above) |
| `airway_metadata.csv` | 0.3 KB | Yes (byte-identical) | Same repository; sample table made from the `colData` of the Bioconductor [`airway`](https://bioconductor.org/packages/airway/) package | CC BY-NC-SA 4.0 (biodatasci); underlying `airway` package LGPL | Love M. *airway* R package, [doi:10.18129/B9.bioc.airway](https://doi.org/10.18129/B9.bioc.airway); Himes et al. 2014 |
| `annotables_grch38.csv` | 7.7 MB | **No** (over 5 MB; `fetch_data.sh airway_tables` downloads it from biodatasci) | Same repository; the `grch38` table of the [annotables](https://github.com/stephenturner/annotables) R package (Stephen Turner), built from Ensembl GRCh38 | annotables package: GPL-3; as distributed in biodatasci: CC BY-NC-SA 4.0; Ensembl data: [no restrictions](https://www.ensembl.org/info/about/legal/disclaimer.html) | Turner S. annotables: Ensembl annotation tables. [github.com/stephenturner/annotables](https://github.com/stephenturner/annotables) |

`sigresults.csv`, which sat next to M4L3 in the live course, is **not** a
biodatasci file. It is the output of the M4L3 cell that writes the
significant DESeq2 results (`padj < 0.05`, 2,186 genes); running the
notebook recreated it with the same rows and values. It is therefore not
committed, and the notebook writes it next to itself when run (the path is
git-ignored).

## Corrections relative to the live course

- `selected_samples.csv` in the live course paired each sample name with a
  GSM accession one replicate off (for example `CRN1-1,GSM2090460`). The
  correct pairs from ENA are CRN1-1 = GSM2090459 (SRR3229095), CRN2-1 =
  GSM2090462 (SRR3229098), CRN3-1 = GSM2090465 (SRR3229101), ORN1-1 =
  GSM2090477 (SRR3229113), ORN2-1 = GSM2090480 (SRR3229116), and ORN3-1 =
  GSM2090483 (SRR3229119). The SRX accessions in the file were correct.
- The example commands in M7L3 listed mouse runs (SRR2087747, SRR2087748,
  SRR2087619) by mistake. They were replaced with the GSE60141 runs for the
  samples named in the text (SRR2926896, SRR2926897, SRR2926068).
- M3P2 downloaded the TAIR10 **CDS** blast set into a file named "cdna". It
  now downloads the cDNA blast set.

## Data not included

- `ExampleRnaSeqRawReads.txt` (a count table for *aig2abc*/*pad4* mutants
  in Modules 1 and 4 resources) was **excluded** because no public accession
  could be found for it.
- `ExampleFastQC100kReads_R1/R2_001.fastq(.gz)` (Module 2) had no recorded
  source. `fetch_data.sh practice` regenerates files with the same names
  from the first 100,000 read pairs of the public run SRR2926068.
- `pGBKT7-53 Control vector sequence.gbk` (a vendor plasmid record) was
  excluded.
- `annotables_grch38.csv` (7.7 MB) is downloaded rather than committed, and
  `sigresults.csv` is regenerated by M4L3 (see above).
