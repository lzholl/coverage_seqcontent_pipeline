# Coverage & Sequence Content Pipeline: Installation Instructions

For this assignment, I have implemented Snakemake as a workflow management system to create a reproducible, scalable, and customizable pipeline. The Snakefile is currently specific to the HIV MiSeq dataset & reference genome given for this assignment but can be generalized.

## Dependencies
* Mambaforge
        *note: this is what worked best for me to run locally & is also recommended by the snakemake developers, but any Conda-based Python3 distribution should work           (e.g. Anaconda3)*
* snakemake (7.12 here, requires at least Python 3.5)
* BWA 0.7.17
* samtools 1.9
* R (4.2.1 used here, but at least 3.1 needed for Qualimap)
* Qualimap 2.2
* SRA toolkit (for data download)

## Installation

1. *Mambaforge & Snakemake*

    download and install Mambaforge:
    
          wget https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh
          bash Mambaforge-Linux-x86_64.sh
    activate base environment and install snakemake:
    
          mamba activate base
          mamba create -c conda-forge -c bioconda -n snakemake snakemake
    to activate snakemake:
          
          mamba activate snakemake
          
    to make the pipeline directory:

          mkdir pipeline
          touch pipeline/Snakefile
---

2. *SRA Toolkit & data download*

    *note: skip if you already have your data ready to go. I did this step within my base environment.*
    
    create environment file:
          
          nano env.yml
    copy and paste into editor:
          
          channels:
           - conda-forge
           - bioconda
           - defaults
          dependencies:
           - sra-tools=2.10.9     
    create conda env & activate it:
    
          mamba env create -n sra -f env.yml
          mamba activate sra
    create data folder:
    
          mkdir data
          
    download fastq files & reference file:
    
          fasterq-dump SRR961514 -O ./data
          wget -q -O - "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=K03455.1&rettype=fasta" > reference.fasta
          
    or use ncbi edirect for more scalable approach:
    
          wget https://www.ncbi.nlm.nih.gov/books/NBK179288/bin/install-edirect.sh
          source ./install-edirect.sh
          esearch -db nucleotide -query "ID" | efetch -format fasta > ID.fasta
---

3. *BWA & samtools*

Mamba has known issues with conflict reporting, making it difficult to install some packages. samtools happens to be one of them, so I created a separate environment for the mapping & alignment tools (nano envs/map.yaml) with the following:

    channels:
     - bioconda
     - conda-forge
    dependencies:
     - bwa=0.7.17
     - samtools=1.9
     
---

4. *R, ggplot2 & Qualimap*

The rest of the packages can be installed via the bioconda or conda-forge channels:

    mamba install -c conda-forge r-base=4.1.3
    mamba install -c conda-forge r-ggplot2=3.3.6
    mamba install -c bioconda qualimap
    
    

