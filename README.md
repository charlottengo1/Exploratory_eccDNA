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

The assembly contains 383,947,622 bp across 99 sequences and has a scaffold N50 of 23,590,137 bp.

## Interim results

### Whole-replicon screening

| Reference | Covered bases | Coverage | Mean depth | Mean MAPQ |
|---|---:|---:|---:|---:|
| Original `MT025716.1` | 399,430 | 99.9987% | 577.187× | 47.9 |
| Rotated `MT025716.1` | 399,430 | 99.9987% | 577.146× | 47.9 |
| Rearranged `PQ252370.1` | 423,568 | 99.3981% | 590.946× | 43.1 |

The high apparent coverage of the rearranged reference does **not** demonstrate that this structure is present. Most of the two replicons is shared, and mapping separately against each target allows the same homologous reads to align to both.

### Circle-compatible adjacency

There were **265** primary HiFi alignments with MAPQ ≥20 extending at least 100 bp to each side of the internalized `MT025716.1` end-to-start adjacency.

This is strong evidence that the adjacency exists in the sample. It is described as “circle-compatible” because the same head-to-tail adjacency could occur between units in a chromosomal tandem array. Sequencing junction evidence alone does not prove physical extrachromosomal localization.

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

## Current interpretation

| Question | Current conclusion |
|---|---|
| Is the original EPSPS replicon sequence amplified? | Strongly supported |
| Does the published end-to-start adjacency exist? | Strongly supported by 265 HiFi reads |
| Is the complete EPSPS+GS2 rearranged replicon present? | Not supported; one required junction has zero reads |
| Is the structure definitively extrachromosomal from sequencing alone? | Not yet; tandem and integrated alternatives must be excluded |
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

1. Align the original replicon to `GCA_051800445.1` and locate all native source segments.
2. Map HiFi reads to the genome alone for unbiased total EPSPS dosage.
3. Locate native EPSPS and GS2 loci by sequence alignment rather than assuming chromosome coordinates transfer between assemblies.
4. Select GC- and mappability-matched single-copy control windows.
5. Map to genome plus versioned eccDNA decoys for structure-aware read assignment.
6. Search for reads connecting EPSPS repeat units to unique chromosome flanks.
7. Call long-read structural variants and perform local assembly around EPSPS.
8. Partition dosage into `eccDNA-supported`, `tandem-supported`, and `unassigned` components only where structure-specific evidence permits.
9. Benchmark against susceptible HiFi runs from the same BioProject.
10. Validate the final model with junction PCR/ddPCR and FISH when real experimental material is available.

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
