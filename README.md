⚠️**PLEASE NOTE**: This tool was called **VOCAL (Variant Of Concern ALert and prioritization)** before!

<div id="top"></div>

<div align="center">
<h1 align="center"> VirusWarn-SC2 </h1>
<h3 align="center"> Mutation-Based Early Warning System to Prioritize Concerning SARS-CoV-2 Variants from Sequencing Data </h3>
</div>

[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A522.10.1-23aa62.svg)](https://www.nextflow.io/)
[![run with conda](https://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)

The goal of VirusWarn-SC2 is to detect SARS-CoV-2 emerging variants from collected bases of genomes, before their annotation by phylogenetic analysis.
It does so by parsing SARS-CoV-2 genomes and detecting amino acids mutations in the spike proteins that can be associated with a phenotypic change. The phenotypic changes are annotated according to the knowledge accumulated on previous variants. Owing to the limited size of the genome, convergent evolution is expected to take place. 

# Documentation

VirusWarn-SC2 is part of *VirusWarn*

<a href="https://rki-mf1.github.io/viruswarn-doc/"><strong>Explore »</strong></a>

For more information take a look at the VirusWarn-SC2 Documentation

<a href="https://rki-mf1.github.io/vocal-doc/"><strong>Explore »</strong></a>


# Getting Started

⚠️ **Note**: 🔌 Right now, VirusWarn-SC2 tested on Linux and Mac system only 💻 

## Quick Installation

To run the pipeline, you need to have `Nextflow` and either `conda`, `Docker` or `Singularity`.

<details><summary><strong>Click!</strong> If you want to install <code>Nextflow</code> directly, you can use the following one-liner. </summary>

```bash
wget -qO- https://get.nextflow.io | bash
```
</details>

<details><summary><strong>Click!</strong> If you want to set up <code>conda</code> to run the pipeline and install all other dependencies through it, you can use the following steps. </summary>

Use the following bash commands if you are working on **Linux**:
```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
```

Use the following bash commands if you are working on **Mac**:
```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh
bash Miniconda3-latest-MacOSX-arm64.sh
```

Then, `Nextflow` an be installed over `conda`:
```bash
conda create -n nextflow -c bioconda nextflow
conda activate nextflow
```
</details>

### Call help

```bash
nextflow run rki-mf1/viruswarn-sc2 -r <version> --help
```

## Running VOCAL

With a `conda`, please run:

```bash
nextflow run rki-mf1/viruswarn-sc2 -r <version> \
     -profile conda,local \
     --fasta 'test/sample-test.fasta'
```

With a `Docker`, please run:

```bash
nextflow run rki-mf1/viruswarn-sc2 -r <version> \
     -profile docker,local \
     --fasta 'test/sample-test.fasta'
```

With a `Singularity`, please run:

```bash
nextflow run rki-mf1/viruswarn-sc2 -r <version> \
     -profile singularity,local \
     --fasta 'test/sample-test.fasta'
```

### With metadata file

```bash
nextflow run rki-mf1/viruswarn-sc2 -r <version> \
     -profile conda,local \
     --fasta 'test/sample-test.fasta' \
     --metadata 'test/meta.tsv' \
     --psl
```

⚠️ **Note**: Metadata must have the following information at least
* ID column (match with sample ID in FASTA file)
* LINEAGE column (e.g., B.1.1.7, BA.1)

### With pblat

🐌 **Slow?**: The alignment option in VOCAL uses a biopython pairwise aligner and can be relatively slow. It is thus recommended to first generate an alignment file of all the sequences before running VOCAL annotation of the mutations. The alignment file (in PSL format) can be created using the tool `pblat` by adding the option `--psl`.

```bash
nextflow run rki-mf1/viruswarn-sc2 -r <version> \
     -profile conda,local \
     --fasta 'test/sample-test.fasta' \
     --psl
```
⚠️ **Note**: When `VirusWarn-SC2` is run without option `--psl`, it realigns each query sequence to the reference sequence Wuhan NC_045512 using the pairwise alignment function in the biopython library.


## Parameter list

```
fasta                    REQUIRED! The path to the fasta file with the sequences for VirusWarn-SC2.
                         [ default: '' ]
metadata                 The path to a metadate file for the sequences.
                         [ default: '' ]
year                     Specify the year from which the information should 
                         be used for the ranking.
                         [ default: 2022 ]
psl                      Run process with pblat alignment.
                         [ default: false ]
strict                   Run process with strict alert levels (without orange).
                         [ default: 'n' ]
```

# How to interprete result.

VirusWarn-SC2 output an alert level in four different colours which can be classified into 3 ratings.

| Alert color      | Description | Impact | 
| ----------- | ----------- | ----------- |
| Pink | Variant is known as VOC/VOI and containing MOC or new mutations.   | HIGH |
| Red | Not VOC/VOI but contain high MOC or ROI, and a new matuation (likely to cause a problem/ new dangerous).  | HIGH |
| Orange | Variant contains moderately muations, or also possibly consider them either VUM or De-escalated variant.   | MODERATE |
| Grey | Near-zero mutation size for MOC or ROI or either no MOC or no ROI.     | LOW |

# Contact

Did you find a bug? 🐛 Suggestion/Feedback/Feature request? 👨‍💻 Please visit [GitHub Issues](https://github.com/rki-mf1/VirusWarn-SC2/issues)

For business inquiries or professional support requests 🍺 
Please feel free to contact us!

# Acknowledgments

* Original Idea: SC2 Evolution Working group - M. von Kleist, S. Clavignac-Spencer

* Funding: Supported by the European Centers for Disease Control [grant number ECDC GRANT/2021/008 ECD.12222].



