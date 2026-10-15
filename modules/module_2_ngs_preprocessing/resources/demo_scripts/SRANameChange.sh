declare -A names=(
  [SRR3229095]=CRN1-1
  [SRR3229098]=CRN2-1
  [SRR3229101]=CRN3-1
  [SRR3229113]=ORN1-1
  [SRR3229116]=ORN2-1
  [SRR3229119]=ORN3-1
)

for srr in "${!names[@]}"; do
  mv ${srr}_1.fastq.gz ${names[$srr]}_1.fastq.gz
  mv ${srr}_2.fastq.gz ${names[$srr]}_2.fastq.gz
done
