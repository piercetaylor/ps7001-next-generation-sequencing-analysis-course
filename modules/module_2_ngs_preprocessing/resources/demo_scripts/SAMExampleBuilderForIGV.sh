#!/bin/bash
#start conda module and load env 
module load miniconda3

source activate dapseq-env

# Set variables
CHROM=1  # chromosome number
FASTA_URL="https://ftp.ebi.ac.uk/ensemblgenomes/pub/release-62/plants/fasta/arabidopsis_thaliana/dna/Arabidopsis_thaliana.TAIR10.dna.chromosome.1.fa.gz"
FASTA_FILE="TAIR10_chr${CHROM}.fasta"

# Step 1: Download the fasta file
wget -O Arabidopsis_thaliana.TAIR10.dna.chromosome.1.fa.gz $FASTA_URL
gunzip -c Arabidopsis_thaliana.TAIR10.dna.chromosome.1.fa.gz > $FASTA_FILE

# Step 2: Index the fasta file with samtools
samtools faidx $FASTA_FILE

# Step 3: Build Bowtie2 index
BOWTIE_IDX="ath_chr${CHROM}"
bowtie2-build $FASTA_FILE $BOWTIE_IDX

# Step 4: Simulate a single paired-end read
READ1="single.read1.fq"
READ2="single.read2.fq"
wgsim -N 1 $FASTA_FILE $READ1 $READ2 > wgsim.out

# Step 5: Align reads with Bowtie2
SAM_FILE="single_pair.sam"
bowtie2 -x $BOWTIE_IDX -1 $READ1 -2 $READ2 -S $SAM_FILE

# Step 6: Convert SAM to BAM
BAM_FILE="single_pair.bam"
samtools view -b -S -o $BAM_FILE $SAM_FILE

# Step 7: Sort and index BAM
SORTED_BAM="single_pair.sorted.bam"
samtools sort -o $SORTED_BAM $BAM_FILE
samtools index $SORTED_BAM

echo "Pipeline complete for chromosome $CHROM."
