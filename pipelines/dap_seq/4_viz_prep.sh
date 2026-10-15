#!/bin/bash
#===============================================================================
# DAP-seq Visualization Preparation
# Author: Pierce Taylor
# Date: December 8, 2025
# Description: Generate coverage tracks, heatmaps, and BigWig files for IGV
#===============================================================================

set -e
set -u
set -o pipefail

#===============================================================================
# Configuration
#===============================================================================
PROJECT_DIR="m7_project"
ALIGN_DIR="${PROJECT_DIR}/results/alignment/bam"
PEAKS_DIR="${PROJECT_DIR}/results/peaks"
VIZ_DIR="${PROJECT_DIR}/results/visualization"
REF_DIR="${PROJECT_DIR}/references/genome"
LOG_DIR="${PROJECT_DIR}/logs"

ENV_NAME="module_7_dapseq"
N_THREADS=8

# Create directories
mkdir -p ${VIZ_DIR}/{bigwig,heatmaps,profiles}

# Create log file
LOGFILE="${LOG_DIR}/viz_prep_$(date +%Y%m%d_%H%M%S).log"
exec 1> >(tee -a "${LOGFILE}")
exec 2>&1

echo "=========================================="
echo "Visualization Preparation Pipeline"
echo "Started: $(date)"
echo "Threads: ${N_THREADS}"
echo "=========================================="

#===============================================================================
# Environment Check
#===============================================================================
echo ""
echo "[STEP 0] Checking environment..."
ml mamba

source activate module_7_dapseq

if [[ "${CONDA_DEFAULT_ENV}" != "${ENV_NAME}" ]]; then
    echo "ERROR: Wrong conda environment!"
    echo "Please activate: conda activate ${ENV_NAME}"
    exit 1
fi

REQUIRED_TOOLS=(deeptools bedGraphToBigWig samtools)
for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v $tool &> /dev/null; then
        echo "ERROR: $tool not found"
        exit 1
    fi
    echo "   $tool"
done

#===============================================================================
# STEP 1: Create Chromosome Sizes File
#===============================================================================
echo ""
echo "=========================================="
echo "[STEP 1] Creating chromosome sizes file"
echo "=========================================="

CHROM_SIZES="${REF_DIR}/TAIR10.chrom.sizes"

if [[ ! -f "${CHROM_SIZES}" ]]; then
    echo "Extracting chromosome sizes from genome..."
    
    # Find the genome file
    GENOME_FA=$(find ${REF_DIR} -name "*.fa" -o -name "*.fasta" | head -1)
    
    if [[ -z "${GENOME_FA}" ]]; then
        echo "ERROR: No genome FASTA found in ${REF_DIR}"
        exit 1
    fi
    
    # Generate chrom.sizes using samtools
    samtools faidx ${GENOME_FA}
    cut -f1,2 ${GENOME_FA}.fai > ${CHROM_SIZES}
    
    echo " Chromosome sizes file created"
else
    echo " Chromosome sizes file exists"
fi

echo ""
echo "Chromosome sizes:"
cat ${CHROM_SIZES}

#===============================================================================
# STEP 2: Generate BigWig Coverage Tracks from BAM
#===============================================================================
echo ""
echo "=========================================="
echo "[STEP 2] Generating BigWig coverage tracks"
echo "=========================================="

for BAM in ${PEAKS_DIR}/markdup/*.markdup.bam; do
    SAMPLE=$(basename ${BAM} .markdup.bam)
    BIGWIG="${VIZ_DIR}/bigwig/${SAMPLE}.bw"
    
    if [[ -f "${BIGWIG}" ]]; then
        echo "   ${SAMPLE}.bw exists, skipping"
        continue
    fi
    
    echo ""
    echo "Processing: ${SAMPLE}"
    
    # Generate BigWig with deepTools bamCoverage
    # RPKM normalization for comparison across samples
    bamCoverage \
        --bam ${BAM} \
        --outFileName ${BIGWIG} \
        --outFileFormat bigwig \
        --binSize 10 \
        --normalizeUsing RPKM \
        --numberOfProcessors ${N_THREADS} \
        --verbose
    
    echo "   ${SAMPLE}.bw created"
done

echo ""
echo " All BigWig files generated"

#===============================================================================
# STEP 3: Convert MACS2 BedGraph to BigWig
#===============================================================================
echo ""
echo "=========================================="
echo "[STEP 3] Converting MACS2 BedGraph to BigWig"
echo "=========================================="

if ls ${PEAKS_DIR}/macs2/*_treat_pileup.bdg 1> /dev/null 2>&1; then
    for BDG in ${PEAKS_DIR}/macs2/*_treat_pileup.bdg; do
        SAMPLE=$(basename ${BDG} _treat_pileup.bdg)
        BIGWIG="${VIZ_DIR}/bigwig/${SAMPLE}_pileup.bw"
        
        if [[ -f "${BIGWIG}" ]]; then
            echo "   ${SAMPLE}_pileup.bw exists, skipping"
            continue
        fi
        
        echo "Converting: ${SAMPLE}"
        
        # Sort bedGraph
        sort -k1,1 -k2,2n ${BDG} > ${BDG}.sorted
        
        # Convert to BigWig
        bedGraphToBigWig ${BDG}.sorted ${CHROM_SIZES} ${BIGWIG}
        
        # Cleanup
        rm ${BDG}.sorted
        
        echo "   ${SAMPLE}_pileup.bw created"
    done
    echo ""
    echo " BedGraph files converted"
else
    echo "No BedGraph files found, skipping"
fi

#===============================================================================
# STEP 4: Compute Matrix for Heatmaps (Peaks)
#===============================================================================
echo ""
echo "=========================================="
echo "[STEP 4] Computing matrix for peak heatmaps"
echo "=========================================="

# For each ARF sample, create heatmap at its peaks
for SAMPLE in GSM1925826_ARF5_rep1 GSM1925827_ARF5_rep2 GSM1925000_ZmARF5 GSM1925138_ARF2 GSM1925137_ARF16; do
    
    PEAK_FILE="${PEAKS_DIR}/macs2/${SAMPLE}_peaks.narrowPeak"
    BIGWIG="${VIZ_DIR}/bigwig/${SAMPLE}.bw"
    MATRIX="${VIZ_DIR}/heatmaps/${SAMPLE}_matrix.gz"
    
    if [[ ! -f "${PEAK_FILE}" ]] || [[ ! -f "${BIGWIG}" ]]; then
        echo "  Skipping ${SAMPLE} (missing files)"
        continue
    fi
    
    echo ""
    echo "Computing matrix: ${SAMPLE}"
    
    # Compute matrix ±2kb around peak summits
    computeMatrix reference-point \
        --referencePoint center \
        --regionsFileName ${PEAK_FILE} \
        --scoreFileName ${BIGWIG} \
        --outFileName ${MATRIX} \
        --beforeRegionStartLength 2000 \
        --afterRegionStartLength 2000 \
        --binSize 10 \
        --numberOfProcessors ${N_THREADS} \
        --skipZeros
    
    echo "   Matrix computed"
    
    # Generate heatmap
    echo "  Generating heatmap..."
    plotHeatmap \
        --matrixFile ${MATRIX} \
        --outFileName ${VIZ_DIR}/heatmaps/${SAMPLE}_heatmap.png \
        --colorMap RdYlBu_r \
        --whatToShow 'heatmap and colorbar' \
        --zMin 0 \
        --zMax 50 \
        --heatmapHeight 15 \
        --refPointLabel "Peak Center"
    
    echo "   Heatmap created"
    
    # Generate profile plot
    echo "  Generating profile plot..."
    plotProfile \
        --matrixFile ${MATRIX} \
        --outFileName ${VIZ_DIR}/profiles/${SAMPLE}_profile.png \
        --perGroup \
        --colors darkblue \
        --plotTitle "${SAMPLE} Signal at Peaks" \
        --refPointLabel "Peak Center"
    
    echo "   Profile plot created"
done

#===============================================================================
# STEP 5: Create IGV Session File
#===============================================================================
echo ""
echo "=========================================="
echo "[STEP 6] Creating IGV session file"
echo "=========================================="

IGV_SESSION="${VIZ_DIR}/dapseq_session.xml"

cat > ${IGV_SESSION} << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<Session genome="tair10" version="8">
    <Resources>
EOF

# Add BigWig tracks
for BW in ${VIZ_DIR}/bigwig/*.bw; do
    NAME=$(basename ${BW} .bw)
    echo "        <Resource path=\"${BW}\"/>" >> ${IGV_SESSION}
done

# Add peak tracks
for PEAK in ${PEAKS_DIR}/macs2/*_peaks.narrowPeak.gz; do
    echo "        <Resource path=\"${PEAK}\"/>" >> ${IGV_SESSION}
done

cat >> ${IGV_SESSION} << 'EOF'
    </Resources>
</Session>
EOF

echo " IGV session file created: ${IGV_SESSION}"


#===============================================================================
# Summary
#===============================================================================
echo ""
echo "=========================================="
echo "Visualization Preparation Complete!"
echo "Finished: $(date)"
echo "=========================================="
echo ""
echo "Output files:"
echo "  BigWig tracks:    ${VIZ_DIR}/bigwig/"
echo "  Heatmaps:         ${VIZ_DIR}/heatmaps/"
echo "  Profile plots:    ${VIZ_DIR}/profiles/"
echo ""
echo "BigWig files generated:"
ls -lh ${VIZ_DIR}/bigwig/*.bw | awk '{print "  " $9 " (" $5 ")"}'
echo ""
echo "  1. View heatmaps: ${VIZ_DIR}/heatmaps/"
echo "  2. Compare with peak files: ${PEAKS_DIR}/macs2/"
echo "  3. Use igv to look for: IAA5, ARF5,TMO5, LBD16, PIN1"
echo ""
echo "Log saved to: ${LOGFILE}"