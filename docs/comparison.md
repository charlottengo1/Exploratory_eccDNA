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
- [x] Chromosome mappings completed
- [x] Mapping-based EPSPS CN estimated
- [x] Unique-k-mer CN estimated
- [x] Replicon comparisons completed
- [ ] Assemblies completed
- [ ] EPSPS graph components classified
- [ ] Chromosome-anchor search completed
- [ ] Final comparative report completed

## Current activity

Both compressed HiFi FASTQs passed `gzip -t`. `SRR30167488` contains 1,517,513 reads totaling 19,581,162,567 bp (mean 12,903.5 bp; N50 16,149 bp; Q20 96.36%; Q30 91.47%). `SRR30167495` contains 1,854,582 reads totaling 22,704,066,842 bp (mean 12,242.1 bp; N50 15,161 bp; Q20 96.47%; Q30 91.76%). GC content is nearly identical at 33.67% and 33.66%. The resistant sample has approximately 16% more sequence, so every locus comparison will use within-sample genome normalization rather than raw counts.

Both samples were mapped to `GCA_051800445.1` with minimap2 2.30 `map-hifi`. The sensitive run has 1,494,316 of 1,517,513 primary reads mapped (98.47%). The mappings contain 2.53 million secondary records in the sensitive sample and 3.27 million in the resistant sample, with similarly abundant supplementary records. These non-primary records are retained for structural analysis but excluded from ordinary copy-number depth.

### Mapping-based EPSPS copy number

The native 9,533-bp EPSPS genomic interval and the same fixed set of 4,831 GC-matched control windows were measured from primary, nonsupplementary alignments with MAPQ at least 20.

| Sample | EPSPS mean | EPSPS median | Control mean | Control median | Mean-based CN | Median-based CN |
|---|---:|---:|---:|---:|---:|---:|
| Kansas-sensitive `SRR30167488` | 47.322× | 49× | 41.333× | 43.700× | 1.145× | 1.121× |
| Tennessee-resistant `SRR30167495` | 3,649.25× | 3,835× | 48.188× | 50.982× | 75.730× | 75.223× |

The sensitive sample is consistent with one native EPSPS copy per haploid genome equivalent. The resistant sample contains approximately **75.5 total EPSPS copies per haploid genome equivalent**, or roughly 74.5 amplified copies above the native locus. The close agreement of mean- and median-normalized estimates indicates that this conclusion is not driven by a small subset of EPSPS bases. This is total dosage; it does not yet allocate the amplified copies between eccDNA and tandem/integrated structures.

### Mapping-independent 31-mer validation

The same 3,153 EPSPS 31-mers that occur exactly once in the chromosome assembly and once in the canonical replicon were counted directly in both FASTQs. The dominant genome histogram modes are approximately 24× in the sensitive sample and 28× in the resistant sample. In these highly heterozygous, outcrossing diploid plants, these are allele-specific modes; the corresponding homozygous single-copy sequence depths are approximately 48× and 56×.

| Sample | Mean marker count | Median marker count | Zero markers | Homozygous baseline | Mean-based CN | Median-based CN |
|---|---:|---:|---:|---:|---:|---:|
| Kansas-sensitive `SRR30167488` | 43.347× | 48× | 35 | ~48× | 0.903× | 1.000× |
| Tennessee-resistant `SRR30167495` | 4,125.29× | 4,150× | 0 | ~56× | 73.666× | 74.107× |

The sensitive mean is lowered by 35 absent markers and population-specific variation, making the median the more robust statistic. The resistant median-based k-mer estimate of **74.1 copies per haploid genome equivalent** agrees within approximately 1.5% of the mapping median estimate of 75.2. The convergent working estimate is therefore approximately **74–75 total EPSPS copies per haploid genome equivalent** in the Tennessee-resistant sample and approximately one copy in the Kansas-sensitive control.

### Study-specific circular reference

`PQ096843.1` was downloaded and validated as a 394,880-bp sequence with 34.01% GC. Five MAPQ-60 alignment blocks place it across essentially the entire `MT025716.1` reference. Its query origin corresponds to approximately `MT025716.1:322,538`, and a later block wraps from the canonical reference end into its beginning. Thus, `PQ096843.1` is principally a rotated, structurally polymorphic version of the original EPSPS replicon rather than a GS2-type rearranged molecule. Small query gaps and larger indel differences remain, so both references are retained for sample-specific mapping and assembly comparison.

### Replicon mapping comparison

| Sample | Reference | Breadth | Mean depth | Primary mapped reads |
|---|---|---:|---:|---:|
| Kansas-sensitive | `MT025716.1` | 48.68% | 455.81× | 272,679 |
| Kansas-sensitive | `PQ096843.1` | 50.17% | 549.15× | 332,405 |
| Tennessee-resistant | `MT025716.1` | 100% | 3,717.62× | 422,203 |
| Tennessee-resistant | `PQ096843.1` | 100% | 3,823.00× | 480,838 |

The sensitive sample's high apparent mean depth is not eccDNA evidence: when a repetitive, chromosome-derived replicon is used as the only reference, many ordinary genomic reads are recruited into the homologous half of the target. Its approximately 50% breadth shows that large parts of either replicon are absent. In contrast, the resistant sample covers every base of both original-like references at very high depth. Consequently, breadth and structure-specific intervals are informative here, whereas target-only mean depth and total mapped-read counts are not valid copy-number estimators.

Primary, nonsupplementary MAPQ-20 depth profiles in 1-kb windows reinforce this distinction. Against `MT025716.1`, the sensitive sample has mean breadth 0.472, only 119 of 400 windows at at least 95% breadth, and 151 completely absent windows; the resistant sample has breadth 1.0 in all 400 windows. Against `PQ096843.1`, the sensitive sample has mean breadth 0.484, 125 of 395 high-breadth windows, and 142 absent windows; the resistant sample again has breadth 1.0 in all 395 windows. The resistant plant therefore contains sequence spanning the entire original-like replicon, while the sensitive signal is restricted to chromosome-derived homologous segments.

Windows with no more than 5% breadth in the sensitive sample and at least 95% breadth in the resistant sample provide a replicon-associated dosage estimate. For `MT025716.1`, 152 such windows have median resistant depth 3,692.64×, corresponding to 72.43 copies after normalization. For `PQ096843.1`, 143 windows have median depth 3,694.67×, corresponding to 72.47 copies. These medians are approximately 96% of the 74–75-copy total EPSPS estimate, indicating that nearly all EPSPS dosage is accompanied by original-like replicon backbone. The lower mean estimates (~65 copies) reflect a subset of structurally variable or less mappable windows and are not interpreted as the number of complete molecules.
