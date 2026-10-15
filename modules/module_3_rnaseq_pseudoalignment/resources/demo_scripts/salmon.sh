#!/bin/bash
set -e

# Paths
TRANSCRIPTOME="references/TAIR10_cdna_20110103_representative_gene_model_updated"
GENEMAP="references/TAIR10_Model_cDNA_associations"
TRIMMED_DIR="data/trimmed"
RESULTS_DIR="results/aligned_counts"
INDEX_DIR="references/salmon_index"

# Build Salmon index if it doesn't exist
if [ ! -d "$INDEX_DIR" ]; then
    echo "Building Salmon index..."
    salmon index -t "$TRANSCRIPTOME" -i "$INDEX_DIR" --no-version-check
else
    echo "Salmon index already exists."
fi

# Quantify each sample
for fq in "$TRIMMED_DIR"/*_R1_trimmed.fastq.gz; do
    sample=$(basename "$fq" "_R1_trimmed.fastq.gz")
    outdir="$RESULTS_DIR/$sample"

    mkdir -p "$outdir"

    echo "Quantifying sample $sample..."
    salmon quant \
        -i "$INDEX_DIR" \
        -l A \
        -r "$fq" \
        --geneMap "$GENEMAP" \
        -p 8 \
        --validateMappings \
        -o "$outdir"
done
