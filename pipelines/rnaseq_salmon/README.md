# Salmon RNA-seq Pipeline

Complete workflow for RNA-seq analysis using Salmon pseudo-alignment

---

## Overview

This pipeline performs complete RNA-seq analysis from raw sequencing data to differential expression and functional enrichment using Salmon's ultra-fast pseudo-alignment approach.

### Pipeline Stages

Raw FASTQ files are processed through fastp for quality control, then quantified with Salmon pseudo-alignment. The quantifications are imported into R using tximport, analyzed for differential expression with DESeq2, and functionally annotated using GO and KEGG enrichment analysis.

Total processing time is approximately 1-2 hours for 12 samples, compared to 6-8 hours with traditional alignment methods.

---

## Quick Start

### 1. Setup Environment

Run the setup script to create the project directory structure and conda environment:

```bash
./0_setup_salmon_pipeline.sh
```

Activate the environment:

```bash
conda activate Salmon_Pipeline
```

### 2. Configure Analysis

Edit the sample sheet at salmon_rnaseq/samples.csv with your SRA accessions:

```text
sample_id,condition,replicate,srr_accession
control_rep1,control,1,SRR1234567
control_rep2,control,2,SRR1234568
control_rep3,control,3,SRR1234569
treated_rep1,treated,1,SRR1234570
treated_rep2,treated,2,SRR1234571
treated_rep3,treated,3,SRR1234572
```

### 3. Download Reference Transcriptome

Navigate to the references directory and download an appropriate transcriptome for your organism:

```bash
cd salmon_rnaseq/references/

# Example: Arabidopsis TAIR10
wget ftp://ftp.ensemblgenomes.org/pub/plants/release-51/fasta/arabidopsis_thaliana/cdna/Arabidopsis_thaliana.TAIR10.cdna.all.fa.gz
gunzip Arabidopsis_thaliana.TAIR10.cdna.all.fa.gz
mv Arabidopsis_thaliana.TAIR10.cdna.all.fa transcriptome.fa

# Example: Human GRCh38
wget ftp://ftp.ensembl.org/pub/release-109/fasta/homo_sapiens/cdna/Homo_sapiens.GRCh38.cdna.all.fa.gz
gunzip Homo_sapiens.GRCh38.cdna.all.fa.gz
mv Homo_sapiens.GRCh38.cdna.all.fa transcriptome.fa

cd ../..
```

### 4. Run Pipeline

Execute the pipeline scripts in order:

```bash
# Part 1: Download, quality control, and quantification
./1_download_and_quantify.sh

# Part 2: Differential expression and enrichment analysis
./2_deseq2_analysis.sh
```

---

## Project Structure

After running the setup script, the following directory structure will be created:

```
salmon_rnaseq/
├── data/
│   ├── raw/                    Downloaded FASTQ files
│   └── trimmed/                Quality-trimmed reads
├── results/
│   ├── salmon/                 Salmon quantifications (quant.sf files)
│   ├── deseq2/                 Differential expression results and normalized counts
│   ├── figures/                All plots including PCA, volcano, and heatmaps
│   └── enrichment/             GO and KEGG enrichment results
├── references/
│   ├── transcriptome.fa        Reference transcriptome (user provides)
│   └── salmon_index/           Salmon index (auto-generated)
├── scripts/
│   └── deseq2_analysis.R       R analysis script (auto-generated)
├── logs/                       Pipeline execution logs
└── samples.csv                 Sample metadata (user edits)
```

---

## Script Details

### Script 0: Setup (0_setup_salmon_pipeline.sh)

Purpose: Initial project setup and environment creation

What it does:
- Creates the complete project directory structure
- Generates the conda environment YAML specification
- Builds the Salmon_Pipeline conda environment with all required packages
- Creates a template sample sheet for user customization

Runtime: Approximately 10-15 minutes

Usage:
```bash
./0_setup_salmon_pipeline.sh
```

---

### Script 1: Download and Quantify (1_download_and_quantify.sh)

Purpose: Data acquisition, quality control, and Salmon quantification

What it does:
1. Downloads RNA-seq data from NCBI SRA using fasterq-dump
2. Performs quality control and adapter trimming with fastp
3. Builds the Salmon transcriptome index (one-time operation)
4. Runs pseudo-alignment and quantification with Salmon
5. Generates comprehensive summary statistics

Key configurable parameters:
- N_THREADS: Number of CPU cores to use (default 8, adjust for your cluster)
- Salmon parameters: Uses validateMappings, gcBias correction, seqBias correction, and 30 bootstraps

Runtime estimates:
- Download: 5-20 minutes per sample (depends on file size and network speed)
- fastp trimming: 2-5 minutes per sample
- Salmon index building: 10-20 minutes (one-time)
- Salmon quantification: 5-20 minutes per sample

Total time for 12 samples: Approximately 1-2 hours

Usage:
```bash
./1_download_and_quantify.sh
```

Output files:
- data/raw/*.fastq.gz: Raw sequencing reads
- data/trimmed/*.trim.fastq.gz: Quality-trimmed reads
- results/salmon/*/quant.sf: Transcript quantifications for each sample
- results/salmon/quantification_summary.txt: Mapping statistics summary

---

### Script 2: DESeq2 Analysis (2_deseq2_analysis.sh)

Purpose: Differential expression analysis and functional enrichment

What it does:
1. Imports Salmon quantifications using tximport
2. Performs differential expression analysis with DESeq2
3. Generates quality control plots including PCA and sample distance heatmaps
4. Creates volcano plots, MA plots, and expression heatmaps
5. Performs GO enrichment analysis for Biological Process, Molecular Function, and Cellular Component
6. Conducts KEGG pathway enrichment analysis
7. Generates a comprehensive summary report

Key configurable parameters (edit these in the script):
```bash
ORGANISM="Hs"                    # Hs for Human, Mm for Mouse, At for Arabidopsis
CONDITION_COLUMN="condition"     # Column name in sample sheet
CONTROL_CONDITION="control"      # Name of control condition
TREATMENT_CONDITION="treated"    # Name of treatment condition
PADJ_CUTOFF=0.05                # Adjusted p-value cutoff
LFC_CUTOFF=1.0                  # Log2 fold change cutoff
```

Runtime: Approximately 5-20 minutes depending on the number of samples

Usage:
```bash
./2_deseq2_analysis.sh
```

Output files:

DESeq2 results:
- deseq2_results_all.csv: Statistics for all genes
- deseq2_significant_genes.csv: Filtered differentially expressed genes
- normalized_counts.csv: Size-factor normalized counts
- rlog_counts.csv: Regularized log-transformed counts for visualization

Figures:
- pca_plot.pdf: Principal component analysis of samples
- sample_distances.pdf: Sample-to-sample correlation heatmap
- dispersion_plot.pdf: DESeq2 dispersion model fit
- ma_plot.pdf: Mean expression versus fold change
- volcano_plot.pdf: Statistical significance versus fold change
- heatmap_top50_genes.pdf: Hierarchical clustering of top genes

Enrichment analysis:
- GO_BP_enrichment.csv: Enriched Biological Process GO terms
- KEGG_enrichment.csv: Enriched KEGG pathways
- GO_BP_dotplot.pdf: Visualization of GO enrichment
- KEGG_dotplot.pdf: Visualization of pathway enrichment

---

## Organism-Specific Configuration

### Supported Organisms

| Organism | Code | Annotation Package | KEGG Code |
|----------|------|-------------------|-----------|
| Human | Hs | org.Hs.eg.db | hsa |
| Mouse | Mm | org.Mm.eg.db | mmu |
| Arabidopsis | At | org.At.tair.db | ath |
| Drosophila | Dm | org.Dm.eg.db | dme |
| C. elegans | Ce | org.Ce.eg.db | cel |
| Rat | Rn | org.Rn.eg.db | rno |
| Zebrafish | Dr | org.Dr.eg.db | dre |

### Installing Organism Annotation Packages

After creating the environment, install the appropriate annotation package in R:

```r
# Start R
R

# Install organism-specific database
BiocManager::install("org.Hs.eg.db")  # For Human
BiocManager::install("org.At.tair.db")  # For Arabidopsis
# Install the appropriate package for your organism

# Exit R
quit()
```

---

## Expected Results

### Mapping Rates
- Good quality data: Greater than 70 percent mapping rate
- Acceptable quality: 50-70 percent mapping rate
- Poor quality: Less than 50 percent mapping rate (investigate sample quality or reference genome mismatch)

### Differential Expression
- Typical RNA-seq experiment: 1,000-5,000 differentially expressed genes (depends on biological effect size)
- Strong biological effect: Greater than 5,000 differentially expressed genes
- Weak biological effect: Fewer than 500 differentially expressed genes

### GO Enrichment
- Expected results: 10-100 enriched terms depending on the number of differentially expressed genes
- All results should have adjusted p-value less than 0.05 after multiple testing correction

---

## Troubleshooting

### Problem: Script reports tool not found

Solution: The conda environment is not activated. Activate it with:
```bash
conda activate Salmon_Pipeline
```

### Problem: Transcriptome file not found error

Solution: You need to download a reference transcriptome to the references directory and name it transcriptome.fa. See the Quick Start section for examples.

### Problem: Low mapping rate (less than 50 percent)

Possible causes:
- Incorrect reference transcriptome (verify you are using the correct species)
- Poor quality sequencing data
- Contamination in samples

Diagnostic steps:
```bash
# Review fastp quality reports
firefox data/trimmed/*_fastp.html

# Check Salmon log files
cat results/salmon/*/logs/salmon_quant.log
```

### Problem: Organism annotation package not installed

Solution: Install the required annotation package in R. For example:
```r
R
BiocManager::install("org.Hs.eg.db")  # Replace with your organism code
quit()
```

### Problem: Script hangs during SRA download

Possible causes:
- NCBI SRA server issues
- Network connectivity problems
- Invalid SRR accession number

Test with a single download:
```bash
prefetch SRR1234567
fasterq-dump SRR1234567
```

### Problem: Out of memory errors

Solutions:
- Request more memory in your cluster job submission
- Reduce the N_THREADS parameter (paradoxically this can help with memory)
- Process samples sequentially instead of in parallel

---

## Running on HPC Clusters with SLURM

If you are running this pipeline on a high-performance computing cluster with SLURM, create a job submission script:

### Example SLURM Submission Script

```bash
#!/bin/bash
#SBATCH --job-name=salmon_rnaseq
#SBATCH --output=logs/salmon_%j.out
#SBATCH --error=logs/salmon_%j.err
#SBATCH --time=06:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --partition=general

# Load required modules
module load mamba

# Activate the conda environment
conda activate Salmon_Pipeline

# Run the pipeline scripts
./1_download_and_quantify.sh
./2_deseq2_analysis.sh
```

Submit the job with:
```bash
sbatch submit_salmon.sh
```

---

## Key References

### Salmon Quantification Method
Patro, R., Duggal, G., Love, M. I., Irizarry, R. A., & Kingsford, C. (2017). Salmon provides fast and bias-aware quantification of transcript expression. Nature Methods, 14(4), 417-419.

Official documentation: https://salmon.readthedocs.io/

### DESeq2 Differential Expression
Love, M. I., Huber, W., & Anders, S. (2014). Moderated estimation of fold change and dispersion for RNA-seq data with DESeq2. Genome Biology, 15(12), 1-21.

DESeq2 vignette: http://bioconductor.org/packages/release/bioc/vignettes/DESeq2/inst/doc/DESeq2.html

### Functional Enrichment Analysis
Yu, G., Wang, L. G., Han, Y., & He, Q. Y. (2012). clusterProfiler: an R package for comparing biological themes among gene clusters. OMICS: A Journal of Integrative Biology, 16(5), 284-287.

clusterProfiler book: https://yulab-smu.top/biomedical-knowledge-mining-book/

---

## Advantages of Salmon Pseudo-Alignment

### Comparison with Traditional Alignment Methods (STAR plus featureCounts)

| Feature | Salmon | Traditional Alignment |
|---------|--------|----------------------|
| Processing time per sample | 5-20 minutes | 1-2 hours |
| Memory requirement | 8-12 GB | 30-40 GB |
| Disk space per sample | 100 MB | 5-20 GB |
| Accuracy | Comparable | Comparable |
| Bias correction | Built-in | Requires manual implementation |
| Multi-mapping read handling | Probabilistic EM algorithm | Typically discarded or randomly assigned |
| Isoform-level quantification | Native support | Difficult to implement |

### When to Use Traditional Alignment Instead

You should use traditional genome alignment methods in the following cases:
- Variant calling requiring BAM files
- Allele-specific expression analysis
- Gene fusion detection
- Novel transcript discovery
- Non-RNA-seq applications such as ChIP-seq or ATAC-seq

---

## Support and Contact

For issues with the pipeline:
- Review log files in salmon_rnaseq/logs/
- Consult Salmon documentation at https://salmon.readthedocs.io/
- For DESeq2 questions visit https://support.bioconductor.org/

Questions about the analysis:
Pierce Taylor (add email address)

---

## Citation

If you use this pipeline in your research, please cite the following papers:

Salmon quantification method:
Patro, R., Duggal, G., Love, M. I., Irizarry, R. A., & Kingsford, C. (2017). Salmon provides fast and bias-aware quantification of transcript expression. Nature Methods, 14(4), 417-419.

DESeq2 differential expression:
Love, M. I., Huber, W., & Anders, S. (2014). Moderated estimation of fold change and dispersion for RNA-seq data with DESeq2. Genome Biology, 15(12), 1-21.

clusterProfiler enrichment analysis:
Yu, G., Wang, L. G., Han, Y., & He, Q. Y. (2012). clusterProfiler: an R package for comparing biological themes among gene clusters. OMICS: A Journal of Integrative Biology, 16(5), 284-287.

---

Last Updated: December 15, 2024  
Pipeline Version: 1.0