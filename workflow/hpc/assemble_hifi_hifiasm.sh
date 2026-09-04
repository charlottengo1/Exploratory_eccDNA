#!/bin/bash
#SBATCH --job-name=hifiasm_epsps
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=32
#SBATCH --mem=128G
#SBATCH --output=logs/hifiasm_%j.out
#SBATCH --error=logs/hifiasm_%j.err

set -euo pipefail

module purge
module load StdEnv/2020
module load hifiasm/0.19.5

PROJECT_DIR=/global/home/hpc6076/projects/epsps-eccdna
READS="$PROJECT_DIR/raw_data/SRR30359588.fastq.gz"
OUTDIR="$PROJECT_DIR/results/assembly"
PREFIX="$OUTDIR/SRR30359588"

mkdir -p "$OUTDIR"
cd "$PROJECT_DIR"

hifiasm \
    -o "$PREFIX" \
    -t "$SLURM_CPUS_PER_TASK" \
    "$READS"

awk '/^S/ { print ">"$2; print $3 }' \
    "$PREFIX.bp.p_ctg.gfa" \
    > "$PREFIX.primary_contigs.fa"

awk '/^S/ { print ">"$2; print $3 }' \
    "$PREFIX.bp.r_utg.gfa" \
    > "$PREFIX.raw_unitigs.fa"

# Hifiasm may emit either an alternate-contig graph or separate phased
# haplotype graphs, depending on the assembly outcome and version.
if [[ -s "$PREFIX.bp.a_ctg.gfa" ]]; then
    awk '/^S/ { print ">"$2; print $3 }' \
        "$PREFIX.bp.a_ctg.gfa" \
        > "$PREFIX.alternate_contigs.fa"
fi

for HAPLOTYPE in hap1 hap2; do
    HAP_GFA="$PREFIX.bp.${HAPLOTYPE}.p_ctg.gfa"
    if [[ -s "$HAP_GFA" ]]; then
        awk '/^S/ { print ">"$2; print $3 }' \
            "$HAP_GFA" \
            > "$PREFIX.${HAPLOTYPE}_contigs.fa"
    fi
done

ls -lh "$OUTDIR"
