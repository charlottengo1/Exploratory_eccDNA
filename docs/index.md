---
title: EPSPS eccDNA versus tandem amplification
description: A reproducible PacBio HiFi workflow for quantifying EPSPS dosage and resolving amplification architecture in Amaranthus palmeri
---

# Resolving EPSPS eccDNA versus tandem amplification

This project develops a reproducible sequencing workflow to estimate total **EPSPS** copy number and determine whether amplified copies are carried on extrachromosomal circular DNA (eccDNA), a chromosome-anchored tandem array, both architectures, or an unresolved structure.

## Current status

The first benchmark uses public PacBio HiFi data from a single glyphosate-resistant *Amaranthus palmeri* MSR2 plant. The sample is expected to carry the original EPSPS-only eccDNA and therefore provides a positive control for circle-compatible junction detection.

| Field | Value |
|---|---|
| SRA run | [SRR30359588](https://www.ncbi.nlm.nih.gov/sra/?term=SRR30359588) |
| BioSample | SAMN43324592 |
| BioProject | [PRJNA1151833](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA1151833) |
| Organism | *Amaranthus palmeri* |
| Sample | MSR2 plant 1, glyphosate-resistant |
| Platform | PacBio Revio HiFi |
| Reads | 802,112 |
| Yield | 11,847,192,487 bases |
| Downloaded FASTQ | 3.6 GB compressed; MD5 verified |

## Reference structures

| Accession | Structure | Length | GC |
|---|---|---:|---:|
| [MT025716.1](https://www.ncbi.nlm.nih.gov/nuccore/MT025716.1) | original EPSPS-only eccDNA | 399,435 bp | 34.39% |
| [PQ252370.1](https://www.ncbi.nlm.nih.gov/nuccore/PQ252370.1) | rearranged EPSPS+GS2 eccDNA | 426,133 bp | 33.96% |

A rotated copy of `MT025716.1` was generated with position 199,718 as the new start. Rotation moves the published FASTA end-to-start adjacency into the middle of a linear reference, allowing ordinary long-read alignment to test it without an artificial contig-edge split.

## Analysis completed

1. Created the HPC project at `/global/home/hpc6076/projects/epsps-eccdna`.
2. Downloaded `SRR30359588` using SRA Toolkit 3.0.9 in a Slurm job.
3. Converted the archive to compressed FASTQ and verified its MD5 checksum.
4. Downloaded and validated both versioned eccDNA references.
5. Generated a rotated original-eccDNA reference.
6. Mapped HiFi reads separately with minimap2 2.30 using `map-hifi`.
7. Measured coverage with samtools 1.22.1.
8. Counted primary MAPQ ≥20 alignments spanning candidate junctions.
9. Aligned the two reference structures directly to define their diagnostic intervals.
10. Downloaded and validated chromosome-level *A. palmeri* assembly `GCA_051800445.1` for genome-normalized copy number and chromosome-flank analysis.
11. Mapped all HiFi reads to the chromosome assembly and identified the unique native EPSPS locus.
12. Tested local EPSPS flanks as potential normalization controls and rejected them because of asymmetric depth, missing coverage, and structural divergence.
13. Completed a genome-wide 10-kb control-window analysis that excludes regions homologous to the eccDNA and requires at least 95% breadth of coverage.

The assembly contains 383,947,622 bp across 99 sequences and has a scaffold N50 of 23,590,137 bp.

## Interim results

### Whole-replicon screening

| Reference | Covered bases | Coverage | Mean depth | Mean MAPQ |
|---|---:|---:|---:|---:|
| Original `MT025716.1` | 399,430 | 99.9987% | 577.187× | 47.9 |
| Rotated `MT025716.1` | 399,430 | 99.9987% | 577.146× | 47.9 |
| Rearranged `PQ252370.1` | 423,568 | 99.3981% | 590.946× | 43.1 |

The high apparent coverage of the rearranged reference does **not** demonstrate that this structure is present. Most of the two replicons is shared, and mapping separately against each target allows the same homologous reads to align to both.

### Published FASTA boundary is not diagnostic of circularity

There were **265** primary HiFi alignments with MAPQ ≥20 extending at least 100 bp to each side of the internalized `MT025716.1` end-to-start boundary. A subsequent 31-mer test showed that every one of the 30 k-mers crossing this boundary occurs many times in the haploid chromosome assembly: observed reference multiplicities range from 31 to 51 copies.

Consequently, the published FASTA origin lies in highly repetitive sequence. The 265 reads validate continuity across this representation boundary but are **not circle-specific evidence** and cannot distinguish eccDNA from genomic repeats or a tandem array. The earlier interpretation of these reads as strong circle-compatible junction evidence is retracted. Circularity must instead be evaluated through assembly-graph closure, structure-specific nonrepetitive adjacencies, absence/presence of chromosome-anchor junctions, and orthogonal physical evidence.

### Original versus rearranged structure

Direct alignment of `PQ252370.1` to `MT025716.1` recovered the expected replacement:

- Original-specific interval: approximately `MT025716.1:84,835–106,924` (~22.1 kb).
- Rearranged GS2-associated insertion: approximately `PQ252370.1:91,943–145,239` (~53.3 kb).

These values agree with the published 21,952-bp deletion and 53,159-bp insertion, allowing for alignment-boundary differences.

| Diagnostic measurement | Result |
|---|---:|
| Original-specific internal interval mean depth | 946.871× |
| Original shared-backbone mean depth | 329.988× |
| GS2-insertion internal interval mean depth | 145.493× |
| Rearranged shared-backbone mean depth | 455.363× |
| Left rearranged backbone–GS2 junction | 45 reads |
| Right rearranged backbone–GS2 junction | 0 reads |

A complete rearranged circle requires both insertion junctions. The absent right junction and depleted GS2-insertion depth argue against a complete `PQ252370.1` structure in this individual. One-sided support may reflect native chromosome 15 sequence, partial homology, an incomplete rearrangement, or mapping artifacts.

### Whole-genome mapping

The 802,112 HiFi reads were mapped to `GCA_051800445.1` with minimap2 `map-hifi` and coordinate-sorted with samtools.

| Metric | Result |
|---|---:|
| Primary reads | 802,112 |
| Primary mapped reads | 800,389 |
| Primary mapping rate | 99.79% |
| Raw sequence yield / assembly length | ~30.86× |
| Primary reads with MAPQ 0 | 23,175 |
| Secondary alignment records | 1,387,998 |
| Supplementary alignment records | 1,382,394 |
| Bases mapped from CIGAR | 10,184,061,775 |

The many non-primary alignments are biologically and analytically relevant: the genome and replicon contain abundant repeated and rearranged sequence. They are retained for later structural analysis but excluded from ordinary depth estimates.

### Native EPSPS locus

The complete 1,599-bp EPSPS transcript `FJ861242.1` was aligned in splice-aware mode. It produced one MAPQ 60 genomic match:

```text
CM122062.1:12,484,568–12,494,100  (1-based)
```

The corresponding locus on the original replicon is:

```text
MT025716.1:135,758–146,025  (1-based)
```

Across the 9,533-bp native genomic interval, primary nonsupplementary MAPQ/base-quality ≥20 coverage was uniform:

| Metric | Result |
|---|---:|
| Mean depth | 257.506× |
| Median depth | 260× |
| Depth SD | 19.570× |
| Minimum / maximum | 195× / 293× |
| Zero-coverage fraction | 0 |

### Why local flanks were rejected as controls

| Candidate baseline | Mean depth | SD | Zero-coverage fraction |
|---|---:|---:|---:|
| 90-kb left flank | 9.957× | 8.336× | 29.12% |
| 100-kb right flank | 16.214× | 8.311× | 0.58% |
| Whole-assembly filtered mean | 19.606× | — | — |

The two flanks disagree strongly and the left flank contains extensive missing coverage. Local alignments also have a high NM-per-read-base value (~0.175), likely reflecting large indels, structural discordance, and replicon-derived split alignments rather than ordinary HiFi substitution error. These regions are unsuitable normalization controls.

Dividing EPSPS median depth by the whole-assembly filtered mean gives 13.26 copies per haploid genome equivalent, but this value is rejected as the primary estimate. The whole-assembly mean is depressed by repeats, gaps, low-mappability sequence, and unplaced contigs.

### Genome-wide control-window estimate

The reference was divided into complete, non-overlapping 10-kb windows on its 17 chromosome-scale sequences. Windows overlapping any ≥500-bp, ≥90%-identity replicon-to-genome alignment plus 20-kb padding were excluded. Depth was calculated from primary nonsupplementary alignments with MAPQ ≥20, and only windows with at least 95% covered bases were retained.

| Metric | Result |
|---|---:|
| Retained control windows | 10,996 |
| Distinct padded eccDNA-homology exclusion intervals | 55 |
| Control mean depth | 24.0967× |
| Control median depth | 24.0964× |
| Control-window SD | 8.8433× |
| EPSPS mean depth / control mean | 10.686× |
| EPSPS median depth / control median | 10.790× |

The current depth-based estimate is therefore approximately **10.7–10.8 EPSPS copies per haploid genome equivalent**, or **21–22 copies per diploid genome equivalent**. “Diploid genome equivalent” is used instead of “copies per cell” because plant tissue may contain mixed ploidy from endoreduplication. The wide control-window SD indicates heterogeneous mapping/CN behavior, so distributional sensitivity analysis and an independent k-mer estimate remain necessary before treating 10.8 as final.

The retained control-depth distribution is broad but has one main mode rather than an obvious second peak at twice the baseline:

| Quantile | 10-kb window mean depth |
|---|---:|
| 5th percentile | 10.333× |
| 25th percentile | 18.614× |
| Median | 24.095× |
| 75th percentile | 29.236× |
| 95th percentile | 37.058× |

The most populated 2× bins are 22–24× (1,133 windows), 24–26× (1,110), and 26–28× (1,056). This supports a central single-copy baseline around 24–26×. Substituting the control interquartile bounds as denominators gives a deliberately conservative sensitivity range of approximately 8.9–14.0 EPSPS copies per haploid genome equivalent. This is a denominator-sensitivity range, not a statistical confidence interval. GC-matched controls and k-mer multiplicity will be used to narrow systematic uncertainty.

### GC-matched preferred depth estimate

The native EPSPS genomic interval has 35.96% GC. Restricting the high-breadth control set to windows within ±2 percentage points of EPSPS GC retained 4,831 controls.

| Metric | Result |
|---|---:|
| EPSPS GC | 35.959% |
| GC-matched control windows | 4,831 |
| GC-matched control mean depth | 25.3712× |
| GC-matched control median depth | 25.576× |
| GC-matched control SD | 8.6862× |
| Mean-based EPSPS CN | 10.1496× |
| Median-based EPSPS CN | 10.1658× |

The preferred mapping-depth estimate is therefore **about 10.16 EPSPS copies per haploid genome equivalent**, equivalent to **about 20.3 copies per 2C diploid genome equivalent**. This is total EPSPS dosage represented in the DNA extraction; it is not yet a numerical partition into eccDNA versus tandem copies.

### Mapping-independent 31-mer validation

Canonical 31-mers were counted directly from the HiFi FASTQ with Jellyfish 2.3.1. EPSPS k-mers were retained only if they occurred exactly once in the haploid chromosome assembly and once in the original replicon, which avoids paralogous/repetitive markers and ensures that each retained k-mer represents one position per EPSPS unit.

| Metric | Result |
|---|---:|
| Conserved, reference-unique EPSPS 31-mers | 3,153 |
| Mean EPSPS 31-mer multiplicity | 282.663× |
| Median EPSPS 31-mer multiplicity | 286× |
| Heterozygous genome k-mer mode | ~14× |
| Homozygous single-copy genome k-mer mode | ~28× |
| Mean-based k-mer CN (`282.663 / 28`) | 10.095× |
| Median-based k-mer CN (`286 / 28`) | 10.214× |

The k-mer estimate of approximately **10.1–10.2 copies per haploid genome equivalent** agrees exceptionally well with the GC-matched mapping estimate of 10.15–10.17. The convergent working estimate is therefore **approximately 10.2 total EPSPS copies per haploid genome equivalent**, or **approximately 20.3 copies per 2C diploid genome equivalent**. Because one native EPSPS copy exists per haploid chromosome complement, this corresponds to roughly nine additional amplified copies per haploid equivalent. The data do not yet assign every additional copy numerically to eccDNA or tandem architecture.

## Current interpretation

| Question | Current conclusion |
|---|---|
| Is the original EPSPS replicon sequence amplified? | Strongly supported |
| Does the published end-to-start boundary establish circularity? | No; all crossing 31-mers occur 31–51 times in the chromosome assembly |
| Is the complete EPSPS+GS2 rearranged replicon present? | Not supported; one required junction has zero reads |
| Is the structure definitively extrachromosomal from sequencing alone? | No; tandem and integrated alternatives remain unresolved |
| What is the absolute EPSPS copy number? | Not yet estimated |

The result is consistent with the published description of `SRR30359588` as the MSR2 glyphosate-resistant individual carrying the original EPSPS-only replicon.

## Why 577× is not the EPSPS copy number

The initial mappings used only a ~400-kb replicon as the reference. Homologous chromosome-derived reads and partial repeat-derived alignments can therefore be attracted to the only available target. Dividing 577× by the paper’s approximate 31× genomic coverage would create a falsely precise copy-number estimate.

Absolute dosage will instead be estimated as:

```text
total EPSPS copies per haploid genome =
    corrected EPSPS depth / median corrected depth of copy-stable single-copy loci
```

This requires mapping to a nonredundant chromosome assembly, checking EPSPS paralogs and mappability, and deriving an empirical baseline from many control windows.

## Next steps

1. Quantify uncertainty from chromosome-block resampling rather than treating adjacent windows as independent.
2. Map to genome plus versioned eccDNA decoys for structure-aware read assignment.
3. Search for reads connecting EPSPS repeat units to unique chromosome flanks.
4. Call long-read structural variants and perform local assembly around EPSPS.
5. Partition dosage into `eccDNA-supported`, `tandem-supported`, and `unassigned` components only where structure-specific evidence permits.
6. Benchmark against susceptible HiFi runs from the same BioProject.
7. Validate the final model with junction PCR/ddPCR and FISH when real experimental material is available.

## Reproducibility rules

- Use versioned accessions for every reference.
- Run downloads and mappings through Slurm, not on the login node.
- Retain raw command logs, software versions, checksums, and intermediate summary tables.
- Count independent parent molecules, not secondary alignments, as junction support.
- Keep circle presence, physical localization, and absolute copy number as separate claims.
- Preserve an `unassigned` category instead of forcing every amplified copy into eccDNA or tandem classes.

## Key references

- Carvalho-Moore P. et al. (2025). [A rearranged *Amaranthus palmeri* extrachromosomal circular DNA confers resistance to glyphosate and glufosinate](https://pmc.ncbi.nlm.nih.gov/articles/PMC11985328/).
- Koo D-H. et al. (2018). [Extrachromosomal circular DNA-based amplification and transmission of herbicide resistance in crop weed *Amaranthus palmeri*](https://pmc.ncbi.nlm.nih.gov/articles/PMC5879691/).
- Zhang P. et al. (2021). [ecc_finder: detection of extrachromosomal circular DNA from sequencing data](https://pmc.ncbi.nlm.nih.gov/articles/PMC8672306/).
- Wanchai V. et al. (2023). [CReSIL: identification of eccDNA from long-read sequences](https://pmc.ncbi.nlm.nih.gov/articles/PMC10144670/).

## Scope

This is an evolving research workflow. Interim classifications are analytical results, not substitutes for physical confirmation of extrachromosomal localization.
