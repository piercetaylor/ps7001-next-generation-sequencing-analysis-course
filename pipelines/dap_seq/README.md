# DAP-seq Analysis Pipeline

**Author:** Pierce Taylor  
**Date:** December 8, 2025  
**Dataset:** GSE60143 (O'Malley et al. 2016) - ARF transcription factor binding

## Pipeline Overview

Analysis of DAP-seq data for Arabidopsis ARF5, ARF2, and ARF16 transcription factors to identify DNA binding sites and characterize TGTC motif spacing patterns.

## Scripts (Run in Order within the Module_7 folder)

### **0_m7_project.sh** - Project Setup
- Creates directory structure
- Builds conda environment with all dependencies
- Loads mamba module for Hellbender HPC

### **1_SRA_fetch.sh** - Download Data
- Downloads 4 samples from SRA (3 ARFs + beads control)
- Uses R1 only from paired-end data
- Parallel download with 8 jobs

### **2_qc_alignment.sh** - QC & Alignment
- FastQC quality control
- Adapter trimming with fastp
- Bowtie2 alignment to TAIR10
- MultiQC report generation

### **3_macs2.sh** - Peak Calling
- Mark duplicates with Picard
- Call peaks with MACS2 vs beads control
- Calculate FRiP scores
- Generate peak statistics

### **4_viz_prep.sh** - Visualization
- Create BigWig tracks (RPKM normalized)
- Generate deepTools heatmaps
- Prepare files for IGV genome browser

### **5_motif.sh** - Motif Discovery
- Extract sequences from top 500 peaks
- HOMER de novo motif discovery
- MEME-ChIP motif analysis
- Identify TGTCGG (AuxRE) motifs

### **6_annotate_peaks.sh** - Gene Annotation
- Annotate peaks to nearest genes
- Categorize as promoter/genic/intergenic
- Generate target gene lists for GO analysis


## Usage
```bash

# Run scripts sequentially
./0_m7_project.sh
./1_SRA_fetch.sh
./2_qc_alignment.sh
./3_macs2.sh
./4_viz_prep.sh
./5_motif.sh
./6_annotate_peaks.sh
```

## Key Output Locations
```
m7_project/
├── results/
│   ├── peaks/macs2/          # Peak calls
│   ├── visualization/bigwig/ # IGV tracks
│   ├── motifs/               # MEME/HOMER results
│   └── annotation/           # Gene lists
└── logs/                     # Pipeline logs
```

**Total runtime:** ~2-3 hours