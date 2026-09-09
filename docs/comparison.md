---
title: Sensitive versus resistant HiFi comparison
description: Comparative EPSPS copy-number and architecture analysis of SRR30167488 and SRR30167495
---

# Sensitive versus resistant EPSPS comparison

[Return to the main workflow](./)

This experiment applies the same copy-number and structural workflow to a glyphosate-sensitive and glyphosate-resistant *Amaranthus palmeri* sample from one PacBio HiFi resequencing study. The sensitive sample provides an empirical negative control for amplification, apparent replicon homology, assembly-graph complexity, and false-positive junction evidence.

## Samples

| Role | Run | BioSample | Sample title | Platform | Reads | Yield | Approximate depth |
|---|---|---|---|---|---:|---:|---:|
| Sensitive control | [SRR30167488](https://www.ncbi.nlm.nih.gov/sra/?term=SRR30167488) | SAMN43072011 | Kansas-sensitive | PacBio Sequel IIe HiFi WGS | 1,517,513 | 19.58 Gb | ~51× |
| Resistant test | [SRR30167495](https://www.ncbi.nlm.nih.gov/sra/?term=SRR30167495) | SAMN43072004 | Tennessee-resistant | PacBio Sequel IIe HiFi WGS | 1,854,582 | ~22.70 Gb | ~59× |

Approximate depths use the 383,947,622-bp chromosome assembly as the denominator. These plants come from different geographic populations, so this is a phenotype-associated comparison rather than an isogenic or population-matched experiment.

## Study context

The runs belong to *A. palmeri* resequencing study `SRP511169` and the International Weed Genomics Consortium genome project. The associated study analyzed runs `SRR30167488–SRR30167495`. Sensitive assemblies generally retained only the native EPSPS locus, whereas resistant samples retained multiple EPSPS-containing contigs and extensive similarity to the canonical eccDNA. A 395-kb circular EPSPS contig from a Georgia-resistant plant was deposited as `PQ096843`.

## Questions

1. Does the resistant sample have higher total EPSPS copy number than the sensitive sample?
2. Does an independent unique-31-mer estimate agree with mapping-based copy number?
3. Is a canonical EPSPS replicon broadly represented only in the resistant sample?
4. Does resistant-sample assembly recover an isolated, high-support EPSPS graph component?
5. Are any amplified paths connected to unique chromosome sequence, supporting tandem integration?
6. Which apparent circle junctions and graph structures also occur in the sensitive control?

## Analysis design

Both samples will be processed using identical references, filters, software versions, and control windows.

| Stage | Primary output | Comparison |
|---|---|---|
| FASTQ validation | read count, bases, length and quality | confirm usable and reasonably balanced yield |
| Chromosome mapping | sorted BAM and mapping QC | mapping rate and callable genome |
| EPSPS depth | primary, non-supplementary MAPQ-filtered depth | GC-matched total CN |
| Unique 31-mers | median EPSPS marker count | mapping-independent CN |
| Replicon mapping | breadth, depth and diagnostic intervals | resistant-specific enrichment |
| Junction testing | independent supporting molecules | subtract sensitive-control background |
| hifiasm assembly | primary, phased and raw-unitig graphs | EPSPS component count and topology |
| Graph audit | component coverage, `rd:i`, external edges | isolated eccDNA-like versus chromosome-anchored path |
| Raw-read anchors | unique chromosome–amplicon junctions | tandem/integration evidence |

## Reference set

- `GCA_051800445.1`: chromosome-level *A. palmeri* assembly used for native EPSPS and genome normalization.
- `MT025716.1`: canonical 399,435-bp EPSPS-only replicon.
- `PQ252370.1`: 426,133-bp rearranged EPSPS+GS2 replicon.
- `PQ096843`: 395-kb circular EPSPS contig reported by the comparison study; to be downloaded and validated before use.
- `FJ861242.1`: complete EPSPS coding transcript used to locate gene-bearing contigs.

## Interpretation rules

- Depth and k-mer multiplicity estimate **total EPSPS dosage**, not molecular topology.
- An end-to-start replicon adjacency alone cannot distinguish a circle from head-to-tail tandem copies.
- A closed, isolated assembly component favors eccDNA but does not constitute physical proof.
- Long reads linking amplified sequence to unique chromosome flanks support tandem or integrated copies.
- Sensitive-sample observations define the background for repeats, mapping artifacts, and native EPSPS structure.
- Numerical partitioning remains `native + eccDNA + tandem/integrated + unassigned`; unsupported copies remain unassigned.

## Status

- [x] Candidate runs selected
- [x] Platform, WGS strategy, read count, and yield verified
- [x] Sensitive phenotype verified as Kansas-sensitive
- [x] Resistant phenotype identified as Tennessee-resistant
- [x] Slurm array download prepared
- [x] FASTQs downloaded
- [x] FASTQ integrity and read statistics verified
- [ ] Chromosome mappings completed
- [ ] Mapping-based EPSPS CN estimated
- [ ] Unique-k-mer CN estimated
- [ ] Replicon comparisons completed
- [ ] Assemblies completed
- [ ] EPSPS graph components classified
- [ ] Chromosome-anchor search completed
- [ ] Final comparative report completed

## Current activity

Both compressed HiFi FASTQs passed `gzip -t`. `SRR30167488` contains 1,517,513 reads totaling 19,581,162,567 bp (mean 12,903.5 bp; N50 16,149 bp; Q20 96.36%; Q30 91.47%). `SRR30167495` contains 1,854,582 reads totaling 22,704,066,842 bp (mean 12,242.1 bp; N50 15,161 bp; Q20 96.47%; Q30 91.76%). GC content is nearly identical at 33.67% and 33.66%. The resistant sample has approximately 16% more sequence, so every locus comparison will use within-sample genome normalization rather than raw counts.
