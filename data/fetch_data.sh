#!/usr/bin/env bash
# =============================================================================
# fetch_data.sh: download the public datasets used in the course into data/.
#
# Nothing downloaded here is committed to git (see .gitignore). Every file
# comes from a public archive, and data/README.md lists the citation and
# terms of use for each one.
#
# Usage:
#   bash data/fetch_data.sh <target> [<target> ...]
#
# Targets:
#   geo        GEO processed files (GSE79275 counts and series matrix,
#              GSE128156 count table, GSE60141 ARF5 narrowPeak)          ~4 MB
#   reference  Ensembl Plants release 62 TAIR10 genome, cDNA, GTF, GFF3,
#              plus TAIR10 blast sets used in Module 3                    ~200 MB
#   blast      BLAST nucleotide database built from the TAIR10 cDNA (Module 1)
#   practice   small practice files for Module 2 (M2P2, M2P3), made from
#              public runs                                                ~10 MB
#   opt3       GSE79275 root RNA-seq FASTQs, 6 runs (Modules 2, 3, 5)      ~6 GB
#   cd         GSE128156 Cd-treated root RNA-seq FASTQs, 6 runs (Module 5) ~6 GB
#   dapseq     GSE60141 DAP-seq FASTQs (ARF5, ARF2, ARF16, beads) (Module 7)
#   gse72548   GSE72548 RNA-seq FASTQs, 24 runs (Module 6 exercise)        large
#   airway     GSE52778 airway RNA-seq FASTQs, 8 runs (reference only)     large
#   small      geo + a check of the committed examples (what Binder needs)
#   all        every target above
#
# Requirements: bash, curl, gzip, awk, head. FASTQ targets use HTTPS downloads from ENA; if
# FASTQ_TOOL=sra is set they use the SRA Toolkit (prefetch +
# fasterq-dump) instead.
# =============================================================================
set -euo pipefail

DATA_DIR="${DATA_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
ENSEMBL_RELEASE="${ENSEMBL_RELEASE:-62}"
ENSEMBL="https://ftp.ebi.ac.uk/ensemblgenomes/pub/plants/release-${ENSEMBL_RELEASE}"
GEO="https://ftp.ncbi.nlm.nih.gov/geo/series"
TAIR="https://www.arabidopsis.org/api/download-files/download?filePath=Genes/TAIR10_genome_release"
FASTQ_TOOL="${FASTQ_TOOL:-ena}"

log() { printf '[fetch_data] %s\n' "$*" >&2; }

download() {  # download URL DEST (skip if present)
    local url=$1 dest=$2
    if [[ -s "$dest" ]]; then log "exists: ${dest#"$DATA_DIR"/}"; return 0; fi
    mkdir -p "$(dirname "$dest")"
    log "downloading ${url}"
    curl -fsSL --retry 3 --retry-delay 5 -o "${dest}.part" "$url"
    mv "${dest}.part" "$dest"
}

# ena_urls SRR: print the ENA FASTQ URLs (without scheme) for a run
ena_urls() {
    curl -fsS --retry 5 --retry-delay 3 "https://www.ebi.ac.uk/ena/portal/api/filereport?accession=$1&result=read_run&fields=fastq_ftp&format=tsv" \
        | tail -n +2 | cut -f2 | tr ';' ' '
}

# stream_head URL NLINES: print the first NLINES lines of a gzipped remote FASTQ
stream_head() {
    set +o pipefail
    curl -fsSL "https://$1" 2>/dev/null | gzip -dc 2>/dev/null | head -n "$2"
    set -o pipefail
}

# fetch_run SRR OUTDIR NAME: save run as OUTDIR/NAME[_1|_2].fastq.gz
fetch_run() {
    local acc=$1 outdir=$2 name=$3
    mkdir -p "$outdir"
    if compgen -G "${outdir}/${name}*.fastq.gz" > /dev/null; then log "exists: ${name}"; return 0; fi
    if [[ "$FASTQ_TOOL" == "sra" ]]; then
        prefetch "$acc" -O "${DATA_DIR}/tmp/sra"
        fasterq-dump "${DATA_DIR}/tmp/sra/${acc}" --split-files -O "$outdir"
        for f in "$outdir/${acc}"*.fastq; do
            gzip "$f"; mv "${f}.gz" "${f/${acc}/${name}}.gz"
        done
        return 0
    fi
    local urls
    urls=$(ena_urls "$acc")
    [[ -n "$urls" ]] || { log "no ENA FASTQ found for ${acc}"; return 1; }
    for u in $urls; do
        local base suffix
        base=$(basename "$u")
        suffix=${base#"$acc"}            # "", "_1.fastq.gz", "_2.fastq.gz", ".fastq.gz"
        download "https://${u}" "${outdir}/${name}${suffix}"
    done
}

# ---------------------------------------------------------------------------
fetch_geo() {
    download "${GEO}/GSE79nnn/GSE79275/suppl/GSE79275_raw_read_counts.txt.gz" "$DATA_DIR/geo/GSE79275/GSE79275_raw_read_counts.txt.gz"
    download "${GEO}/GSE79nnn/GSE79275/matrix/GSE79275_series_matrix.txt.gz"   "$DATA_DIR/geo/GSE79275/GSE79275_series_matrix.txt.gz"
    download "${GEO}/GSE128nnn/GSE128156/suppl/GSE128156_count_table_Cd_samples_McInturf_2019.txt.gz" \
             "$DATA_DIR/geo/GSE128156/GSE128156_count_table_Cd_samples_McInturf_2019.txt.gz"
    download "${GEO}/GSE60nnn/GSE60141/suppl/GSE60141_DAPSeq-ARF_ecoli-MP_col-chr1-5_GEM_events.narrowPeak.gz" \
             "$DATA_DIR/geo/GSE60141/GSE60141_DAPSeq-ARF_ecoli-MP_col-chr1-5_GEM_events.narrowPeak.gz"
    for f in "$DATA_DIR/geo/GSE79275/GSE79275_raw_read_counts.txt" "$DATA_DIR/geo/GSE79275/GSE79275_series_matrix.txt"; do
        [[ -s "$f" ]] || gzip -dc "${f}.gz" > "$f"
    done
}

fetch_reference() {
    local r="$DATA_DIR/reference/ensembl_plants_${ENSEMBL_RELEASE}"
    download "${ENSEMBL}/fasta/arabidopsis_thaliana/dna/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa.gz" "$r/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa.gz"
    download "${ENSEMBL}/fasta/arabidopsis_thaliana/cdna/Arabidopsis_thaliana.TAIR10.cdna.all.fa.gz"   "$r/Arabidopsis_thaliana.TAIR10.cdna.all.fa.gz"
    download "${ENSEMBL}/gtf/arabidopsis_thaliana/Arabidopsis_thaliana.TAIR10.${ENSEMBL_RELEASE}.gtf.gz"  "$r/Arabidopsis_thaliana.TAIR10.${ENSEMBL_RELEASE}.gtf.gz"
    download "${ENSEMBL}/gff3/arabidopsis_thaliana/Arabidopsis_thaliana.TAIR10.${ENSEMBL_RELEASE}.gff3.gz" "$r/Arabidopsis_thaliana.TAIR10.${ENSEMBL_RELEASE}.gff3.gz"
    local t="$DATA_DIR/reference/tair10"
    download "${TAIR}/TAIR10_blastsets/TAIR10_cdna_20110103_representative_gene_model_updated" "$t/TAIR10_cdna_20110103_representative_gene_model_updated.fasta"
    download "${TAIR}/TAIR10_gff3/TAIR10_GFF3_genes.gff" "$t/TAIR10_GFF3_genes.gff"
    download "${TAIR}/TAIR10_gene_transcript_associations/TAIR10_Model_cDNA_associations" "$t/TAIR10_Model_cDNA_associations"
}

fetch_blast() {
    fetch_reference
    local cdna="$DATA_DIR/reference/ensembl_plants_${ENSEMBL_RELEASE}/Arabidopsis_thaliana.TAIR10.cdna.all.fa"
    [[ -s "$cdna" ]] || gzip -dc "${cdna}.gz" > "$cdna"
    mkdir -p "$DATA_DIR/blast"
    if command -v makeblastdb > /dev/null; then
        makeblastdb -in "$cdna" -dbtype nucl -parse_seqids -out "$DATA_DIR/blast/tair10_db"
    else
        log "makeblastdb not found (install blast from bioconda); skipping database build"
    fi
}

fetch_practice() {
    fetch_reference
    local p="$DATA_DIR/practice"
    local cdna_gz="$DATA_DIR/reference/ensembl_plants_${ENSEMBL_RELEASE}/Arabidopsis_thaliana.TAIR10.cdna.all.fa.gz"
    mkdir -p "$p/m2p2" "$p/m2p3/data"
    # M2P2: full cDNA FASTA plus the iron-homeostasis subset
    [[ -s "$p/m2p2/Arabidopsis_thaliana.TAIR10.cdna.all.fa" ]] || gzip -dc "$cdna_gz" > "$p/m2p2/Arabidopsis_thaliana.TAIR10.cdna.all.fa"
    awk 'NR==FNR{ids[$1]=1; next} /^>/{keep=(substr($1,2) in ids)} keep' \
        "$DATA_DIR/examples/Potential_Iron_Homeostasis_Genes_Arabidopsis.txt" \
        "$p/m2p2/Arabidopsis_thaliana.TAIR10.cdna.all.fa" > "$p/m2p2/Potential_Iron_Homeostasis_Genes_Arabidopsis_cDNA.fa"
    # M2P2: small FASTQ (first 250 reads of SRR1971253, Tan et al. 2015)
    stream_head "$(ena_urls SRR1971253 | awk '{print $1}')" 1000 > "$p/m2p2/small_SRR1971253.fastq"
    # M2P3: 100,000 read pairs from the GSE60141 beads-only control (SRR2926068)
    local u
    for u in $(ena_urls SRR2926068); do
        case "$u" in
            *_1.fastq.gz) stream_head "$u" 400000 | gzip > "$p/m2p3/data/ExampleFastQC100kReads_R1_001.fastq.gz" ;;
            *_2.fastq.gz) stream_head "$u" 400000 | gzip > "$p/m2p3/data/ExampleFastQC100kReads_R2_001.fastq.gz" ;;
        esac
    done
}

fetch_opt3() {   # GSE79275 roots, replete Fe: Col-0 (CRN) and opt3-2 (ORN), technical replicate 1
    local o="$DATA_DIR/fastq/GSE79275"
    fetch_run SRR3229095 "$o" CRN1-1
    fetch_run SRR3229098 "$o" CRN2-1
    fetch_run SRR3229101 "$o" CRN3-1
    fetch_run SRR3229113 "$o" ORN1-1
    fetch_run SRR3229116 "$o" ORN2-1
    fetch_run SRR3229119 "$o" ORN3-1
}

fetch_cd() {     # GSE128156 roots, 72 h Cd: Col-0 (CRT) and opt3-2 (ORT), technical replicate 1
    local o="$DATA_DIR/fastq/GSE128156"
    fetch_run SRR8713301 "$o" CRT1-Col_root_treated_1-1
    fetch_run SRR8713304 "$o" CRT2-Col_root_treated_2-1
    fetch_run SRR8713307 "$o" CRT3-Col_root_treated_3-1
    fetch_run SRR8713319 "$o" ORT1-opt3-2_root_treated_1-1
    fetch_run SRR8713322 "$o" ORT2-opt3-2_root_treated_2-1
    fetch_run SRR8713325 "$o" ORT3-opt3-2_root_treated_3-1
}

fetch_dapseq() { # GSE60141 (O'Malley et al. 2016)
    local o="$DATA_DIR/dapseq/GSE60141"
    fetch_run SRR2926068 "$o" GSM1924998_control_beads
    fetch_run SRR2926896 "$o" GSM1925826_ARF5_rep1
    fetch_run SRR2926897 "$o" GSM1925827_ARF5_rep2
    fetch_run SRR2926208 "$o" GSM1925138_ARF2
    fetch_run SRR2926207 "$o" GSM1925137_ARF16
}

fetch_gse72548() { # Shanks et al. 2016, all 24 runs (SRR2221833-SRR2221856)
    local o="$DATA_DIR/fastq/GSE72548" i
    for i in $(seq 2221833 2221856); do fetch_run "SRR${i}" "$o" "SRR${i}"; done
}

fetch_airway() {  # Himes et al. 2014 (GSE52778); same runs as the Bioconductor airway package
    local o="$DATA_DIR/fastq/GSE52778" a
    for a in SRR1039508 SRR1039509 SRR1039512 SRR1039513 SRR1039516 SRR1039517 SRR1039520 SRR1039521; do
        fetch_run "$a" "$o" "$a"
    done
}

check_examples() {
    local f
    for f in ExampleFasta.txt Potential_Iron_Homeostasis_Genes_Arabidopsis.txt Common_Genes_Arabidopsis.txt ATOPT3.fa; do
        [[ -s "$DATA_DIR/examples/$f" ]] || { log "missing committed example file: $f"; return 1; }
    done
    log "committed example files present"
}

[[ $# -ge 1 ]] || { sed -n '2,32p' "$0"; exit 1; }
for target in "$@"; do
    case "$target" in
        geo)       fetch_geo ;;
        reference) fetch_reference ;;
        blast)     fetch_blast ;;
        practice)  fetch_practice ;;
        opt3)      fetch_opt3 ;;
        cd)        fetch_cd ;;
        dapseq)    fetch_dapseq ;;
        gse72548)  fetch_gse72548 ;;
        airway)    fetch_airway ;;
        small)     check_examples; fetch_geo ;;
        all)       check_examples; fetch_geo; fetch_reference; fetch_blast; fetch_practice
                   fetch_opt3; fetch_cd; fetch_dapseq; fetch_gse72548; fetch_airway ;;
        *) log "unknown target: $target"; exit 1 ;;
    esac
done
log "done"
