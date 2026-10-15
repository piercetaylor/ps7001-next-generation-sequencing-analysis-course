# STAR RNA-seq Alignment Pipeline

Complete workflow for RNA-seq analysis using STAR genome alignment

---

## Overview

This pipeline performs complete RNA-seq analysis using STAR (Spliced Transcripts Alignment to a Reference), which aligns reads directly to the reference genome. This approach is more suitable than pseudo-alignment when you need to detect novel transcripts, call variants, or perform allele-specific expression analysis.

### Pipeline Stages

Raw FASTQ files are processed through fastp for quality control, then aligned to the reference genome using STAR. Gene expression is quantified with featureCounts, and normalized coverage tracks are generated for genome browser visualization. All quality metrics are aggregated with MultiQC.

Total processing time is approximately 2-4 hours for 12 samples on a system with 16 CPU cores and 32 GB of RAM.

---

## Quick Start

### 1. Setup Environment

Run the setup script to create the project directory structure and conda environment:

```bash
./0_setup_star_pipeline.sh
```

Activate the environment:

```bash
conda activate module_5_STAR
```

### 2. Configure Analysis

Edit the sample sheet at star_rnaseq/samples.csv with your SRA accessions:

```text
sample_id,condition,replicate,srr_accession
control_rep1,control,1,SRR1234567
control_rep2,control,2,SRR1234568
control_rep3,control,3,SRR1234569
treated_rep1,treated,1,SRR1234570
treated_rep2,treated,2,SRR1234571
treated_rep3,treated,3,SRR1234572
```

### 3. Download Reference Genome and Annotation

Navigate to the references directory and download appropriate files for your organism:

```bash
cd star_rnaseq/references/

# Example: Arabidopsis TAIR10
# Download genome
wget ftp://ftp.ensemblgenomes.org/pub/plants/release-51/fasta/arabidopsis_thaliana/dna/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa.gz
gunzip Arabidopsis_thaliana.TAIR10.dna.toplevel.fa.gz
mv Arabidopsis_thaliana.TAIR10.dna.toplevel.fa genome/genome.fa

# Download annotation
wget ftp://ftp.ensemblgenomes.org/pub/plants/release-51/gtf/arabidopsis_thaliana/Arabidopsis_thaliana.TAIR10.51.gtf.gz
gunzip Arabidopsis_thaliana.TAIR10.51.gtf.gz
mv Arabidopsis_thaliana.TAIR10.51.gtf annotation/annotation.gtf

# Example: Human GRCh38
# Download genome
wget ftp://ftp.ensembl.org/pub/release-109/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
gunzip Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
mv Homo_sapiens.GRCh38.dna.primary_assembly.fa genome/genome.fa

# Download annotation
wget ftp://ftp.ensembl.org/pub/release-109/gtf/homo_sapiens/Homo_sapiens.GRCh38.109.gtf.gz
gunzip Homo_sapiens.GRCh38.109.gtf.gz
mv Homo_sapiens.GRCh38.109.gtf annotation/annotation.gtf

cd ../..
```

### 4. Run Pipeline

Execute the alignment pipeline:

```bash
./1_download_and_align.sh
```

---

## Project Structure

After running the setup script, the following directory structure will be created:

```
star_rnaseq/
├── data/
│   ├── raw/                    Downloaded FASTQ files
│   └── trimmed/                Quality-trimmed reads
├── results/
│   ├── alignment/
│   │   └── bam/                BAM alignment files and STAR logs
│   ├── counts/                 featureCounts gene quantification
│   ├── qc/                     Quality control reports
│   │   ├── fastp/              fastp trimming reports
│   │   ├── multiqc/            Aggregated QC report
│   │   └── qualimap/           BAM quality statistics (optional)
│   └── tracks/                 BigWig files for genome browsers
├── references/
│   ├── genome/
│   │   └── genome.fa           Reference genome (user provides)
│   ├── annotation/
│   │   └── annotation.gtf      Gene annotation (user provides)
│   └── star_index/             STAR genome index (auto-generated)
├── scripts/                    Analysis scripts (auto-generated)
├── logs/                       Pipeline execution logs
└── samples.csv                 Sample metadata (user edits)
```

---

## Script Details

### Script 0: Setup (0_setup_star_pipeline.sh)

Purpose: Initial project setup and environment creation

What it does:
- Creates the complete project directory structure
- Generates the conda environment YAML specification
- Builds the module_5_STAR conda environment with all required tools
- Creates a template sample sheet for user customization

Runtime: Approximately 5-10 minutes

Usage:
```bash
./0_setup_star_pipeline.sh
```

---

### Script 1: Download and Align (1_download_and_align.sh)

Purpose: Complete data processing from download through quantification

What it does:
1. Downloads RNA-seq data from NCBI SRA using fasterq-dump
2. Performs quality control and adapter trimming with fastp
3. Builds the STAR genome index (one-time operation requiring 30-40 GB RAM)
4. Aligns reads to the reference genome using STAR two-pass mode
5. Quantifies gene expression with featureCounts
6. Generates normalized BigWig coverage tracks for genome browsers
7. Creates a comprehensive MultiQC quality control report
8. Generates alignment summary statistics

Key configurable parameters:
- N_THREADS: Number of CPU cores to use (default 16 for STAR)
- STAR parameters: Two-pass mode, sorted BAM output, gene counts
- featureCounts: Unstranded by default, can be adjusted for stranded libraries

Runtime estimates:
- Download: 5-20 minutes per sample depending on file size
- fastp trimming: 2-5 minutes per sample
- STAR index building: 30-60 minutes (one-time, requires 30-40 GB RAM)
- STAR alignment: 10-30 minutes per sample
- featureCounts: 5-10 minutes total
- BigWig generation: 5-10 minutes per sample

Total time for 12 samples: Approximately 2-4 hours

Usage:
```bash
./1_download_and_align.sh
```

Output files:

Alignment files:
- *_Aligned.sortedByCoord.out.bam: Coordinate-sorted BAM files
- *_Log.final.out: STAR alignment statistics for each sample
- *_ReadsPerGene.out.tab: Per-gene read counts from STAR

Quantification:
- gene_counts.txt: Full featureCounts output with gene information
- gene_counts_matrix.txt: Clean counts matrix ready for DESeq2

Quality control:
- fastp/*.html: Per-sample quality and trimming reports
- multiqc/star_rnaseq_multiqc_report.html: Aggregated QC across all samples
- alignment_summary.txt: Summary of mapping statistics

Visualization:
- tracks/*.bw: RPKM-normalized BigWig files for IGV or UCSC Genome Browser

---

## Important Notes About STAR

### Memory Requirements

STAR requires substantial memory during index building and alignment:
- Index building: 30-40 GB RAM for human genome
- Alignment: 30 GB RAM loaded into shared memory
- Consider using shared memory mode (--genomeLoad LoadAndKeep) if running many samples

### STAR Two-Pass Mode

This pipeline uses STAR two-pass mode, which:
- First pass: Aligns reads to detect novel splice junctions
- Second pass: Re-aligns using both annotated and newly discovered junctions
- Results in improved alignment accuracy, especially for novel isoforms
- Adds approximately 50 percent more runtime but significantly improves results

### Strand Specificity

The featureCounts step uses unstranded counting by default (-s 0). Adjust based on your library preparation:
- -s 0: Unstranded (default)
- -s 1: Stranded (first read matches gene strand)
- -s 2: Reverse stranded (second read matches gene strand, most common for Illumina)

Check your library protocol or examine STAR output to determine strandedness.

---

## Expected Results

### Mapping Rates
- Good quality data: Greater than 70 percent uniquely mapped reads
- Acceptable quality: 60-70 percent uniquely mapped
- Poor quality: Less than 60 percent (investigate issues)

Typical breakdown:
- Uniquely mapped: 70-85 percent
- Multi-mapped reads: 5-15 percent
- Unmapped reads: 5-20 percent

### Gene Detection
- Typical mammalian experiment: 15,000-20,000 genes with non-zero counts
- Typical plant experiment: 20,000-30,000 genes detected
- Genes with substantial expression (greater than 10 counts): 10,000-15,000

---

## Comparison: STAR vs Salmon

### When to Use STAR (Genome Alignment)

Use STAR when you need:
- Variant calling from RNA-seq data
- Allele-specific expression analysis
- Novel transcript or isoform discovery
- Fusion gene detection
- Visualization of alignments in genome browsers
- Integration with other genomic data (ChIP-seq, ATAC-seq)

### When to Use Salmon (Pseudo-alignment)

Use Salmon when you need:
- Faster processing (5-10x speed improvement)
- Lower computational requirements (less RAM, disk space)
- Standard differential expression analysis
- Isoform-level quantification with uncertainty estimates
- No need for BAM files

### Resource Comparison

| Feature | STAR | Salmon |
|---------|------|--------|
| Processing time per sample | 10-30 minutes | 5-10 minutes |
| Memory requirement | 30-40 GB | 8-12 GB |
| Disk space per sample | 5-20 GB (BAM files) | 100 MB (quant files) |
| Index building time | 30-60 minutes | 10-20 minutes |
| Suitable for variant calling | Yes | No |
| Novel transcript discovery | Yes | No |

---

## Troubleshooting

### Problem: Script reports tool not found

Solution: The conda environment is not activated. Activate it with:
```bash
conda activate module_5_STAR
```

### Problem: Genome or annotation file not found

Solution: You need to download reference files to the appropriate directories. See the Quick Start section for examples. Make sure file names match exactly:
- Genome: star_rnaseq/references/genome/genome.fa
- Annotation: star_rnaseq/references/annotation/annotation.gtf

### Problem: STAR index building fails with memory error

Possible causes:
- Insufficient RAM (STAR needs 30-40 GB for human genome)
- Too many threads specified

Solutions:
- Request more memory in your cluster job submission
- Reduce N_THREADS to 8 or fewer
- Use a pre-built STAR index if available

### Problem: Low mapping rate (less than 60 percent)

Possible causes:
- Wrong reference genome (verify species and version match)
- Poor quality sequencing data
- Contamination
- Incorrect library type (check strand specificity)

Diagnostic steps:
```bash
# Check fastp reports
firefox star_rnaseq/results/qc/fastp/*_fastp.html

# Review STAR alignment logs
cat star_rnaseq/results/alignment/bam/*_Log.final.out

# Check MultiQC report
firefox star_rnaseq/results/qc/multiqc/star_rnaseq_multiqc_report.html
```

### Problem: STAR fails with "Genome version incompatible" error

Solution: The STAR version used to build the index differs from the version running alignment. Rebuild the index:
```bash
rm -rf star_rnaseq/references/star_index/*
./1_download_and_align.sh
```

### Problem: featureCounts returns zero counts for all genes

Possible causes:
- GTF file does not match the genome version
- Incorrect feature type or gene ID attribute
- Strand specificity mismatch

Solutions:
- Verify GTF and genome are from the same source and version
- Check GTF file format: less star_rnaseq/references/annotation/annotation.gtf
- Try different strand settings: -s 0, -s 1, or -s 2

### Problem: Out of disk space

STAR alignments generate large files. Required space per sample:
- BAM file: 5-20 GB
- Temporary files during alignment: 20-50 GB
- BigWig tracks: 500 MB - 2 GB

Solutions:
- Ensure adequate disk space before starting (100-200 GB recommended)
- Delete temporary STAR files after alignment: rm */_STARtmp/
- Compress or move raw FASTQ files after alignment completes

---

## Running on HPC Clusters with SLURM

STAR is computationally intensive and benefits from cluster resources.

### Example SLURM Submission Script

```bash
#!/bin/bash
#SBATCH --job-name=star_rnaseq
#SBATCH --output=logs/star_%j.out
#SBATCH --error=logs/star_%j.err
#SBATCH --time=08:00:00
#SBATCH --cpus-per-task=16
#SBATCH --mem=40G
#SBATCH --partition=general

# Load required modules
module load mamba

# Activate conda environment
conda activate module_5_STAR

# Run pipeline
./1_download_and_align.sh
```

Submit the job:
```bash
sbatch submit_star.sh
```

### Resource Recommendations

For STAR alignment on HPC:
- CPUs: 16 cores (can use 8 if limited)
- Memory: 40 GB minimum (50 GB recommended for large genomes)
- Time: 8 hours for index building plus alignment of 12 samples
- Disk: 200 GB temporary space

---

## Downstream Analysis

### Using Gene Counts with DESeq2

The gene_counts_matrix.txt file can be directly imported into DESeq2 for differential expression analysis. Example R code:

```r
library(DESeq2)

# Read counts
counts <- read.table("star_rnaseq/results/counts/gene_counts_matrix.txt", 
                     header=TRUE, row.names=1)

# Read sample metadata
coldata <- read.csv("star_rnaseq/samples.csv", row.names=1)

# Create DESeq2 dataset
dds <- DESeqDataSetFromMatrix(countData = counts,
                               colData = coldata,
                               design = ~ condition)

# Run DESeq2
dds <- DESeq(dds)
results <- results(dds)
```

### Viewing Alignments in IGV

Load the BAM files and BigWig tracks into IGV (Integrative Genomics Viewer):

1. Open IGV and load your reference genome
2. File > Load from File > Select BAM files from results/alignment/bam/
3. File > Load from File > Select BigWig files from results/tracks/
4. Navigate to genes of interest to view coverage and splice junctions

---

## Key References

### STAR Aligner
Dobin, A., Davis, C. A., Schlesinger, F., et al. (2013). STAR: ultrafast universal RNA-seq aligner. Bioinformatics, 29(1), 15-21.

Official documentation: https://github.com/alexdobin/STAR/blob/master/doc/STARmanual.pdf

### featureCounts
Liao, Y., Smyth, G. K., & Shi, W. (2014). featureCounts: an efficient general purpose program for assigning sequence reads to genomic features. Bioinformatics, 30(7), 923-930.

### MultiQC
Ewels, P., Magnusson, M., Lundin, S., & Kaller, M. (2016). MultiQC: summarize analysis results for multiple tools and samples in a single report. Bioinformatics, 32(19), 3047-3048.

---

## Citation

If you use this pipeline in your research, please cite:

STAR aligner:
Dobin, A., Davis, C. A., Schlesinger, F., Drenkow, J., Zaleski, C., Jha, S., Batut, P., Chaisson, M., & Gingeras, T. R. (2013). STAR: ultrafast universal RNA-seq aligner. Bioinformatics, 29(1), 15-21.

featureCounts:
Liao, Y., Smyth, G. K., & Shi, W. (2014). featureCounts: an efficient general purpose program for assigning sequence reads to genomic features. Bioinformatics, 30(7), 923-930.

---

Last Updated: December 15, 2024  
Pipeline Version: 1.0