# Coverage & Sequence Content Pipeline: README!

For this assignment, I have implemented Snakemake as a workflow management system to create a reproducible, scalable, and customizable pipeline. The Snakefile is currently specific to the HIV MiSeq dataset & reference genome given for this assignment but can be generalized. The steps are broken into several modules (or snakemake "rules") that are described below.

## Dependencies & Installation

See INSTALL.md!

## Run Instructions

*note: this is assuming you have completed every step of the install file!*

Within your pipeline folder (wherever your Snakefile is located), you can run the entire pipeline using the command:

    snakemake --use-conda --cores-1
    
A dry-run (for troubleshooting purposes, no outputs) can be performed with:

    snakemake --use-conda -n
    
A specific rule can be run with:

    snakemake --use-conda -R rulename
    
OR by setting a specific target file (an output from one of the rules):

    snakemake --use-conda /path/to/target
    
# Modules

#### Index the reference genome using BWA.

    rule index:
        input:
            "data/reference.fasta" 
        output:
            "data/reference.fasta.bwt" 
        conda:
            "envs/map.yaml" 
        shell:
            "bwa index {input}"
            
The input can be generalized by replacing 'reference' with {genome}. 
The output will include several index files with various file formats. 
The environment for the mapping & alignment tools that was created is invoked using the conda directive.
The shell directive invokes a generalized command for the program that you are running.

#### Map the paired reads to the reference genome.

    rule map_reads:
        input:
            "data/reference.fasta",
            "data/miseq/SRR961514_1.fastq",
            "data/miseq/SRR961514_2.fastq"
        output:
            "results/mapped/q{q}/hiv.bam"
        conda:
            "envs/map.yaml"
        params:
            q = config["quality_filter"]
        shell:
            "bwa mem {input} | samtools view -S -b -q {wildcards.q} - > {output}"

Multiple files must be separated by commas (see input). As is, the files will be written sequentially.
The parameter "q" is defined using the config file and can be used to generalize the output. {wildcards.q} within the shell directive acts as a placeholder for q since it is a range of values.

#### Sort by name & clean up alignment file (rule fix), sort by coordinate order (rule sort), & remove duplicates (rule dedup).

    rule fix:
      input:
          "results/mapped/q{q}/hiv.bam"
      output:
          "results/mapped/q{q}/hiv.fix.bam"
      conda:
          "envs/map.yaml"
      shell:
          "samtools sort -n {input} | samtools fixmate -m - {output}"

    rule sort:
        input:
            "results/mapped/q{q}/hiv.fix.bam"
        output:
            "results/mapped/q{q}/hiv.sorted.bam"
        conda:
            "envs/map.yaml"
        shell:
            "samtools sort -o {output} {input}"

    rule dedup:
        input:
            "results/mapped/q{q}/hiv.sorted.bam"
        output:
            "results/mapped/q{q}/hiv.sorted.dedup.bam"
        conda:
            "envs/map.yaml"
        shell:
            "samtools markdup -r -S {input} {output}"
#### Calculate read depth (depth.tsv has contig name, bp position, and # of mapped reads at each position).

    rule depth:
        input:
            "results/mapped/q{q}/hiv.sorted.dedup.bam"
        output:
            "results/mapped/q{q}/depth.tsv"
        conda:
            "envs/map.yaml"
        shell:
            "samtools depth {input} > {output}"

#### Use an R script to reformat depth.tsv to the final coverage.tsv output and plot the coverage across the reference sequence.

    rule cov_plot:
         input:
            tsv="results/mapped/q{q}/depth.tsv"
         output:
            tsv="results/mapped/q{q}/coverage.tsv",
            pdf="results/mapped/q{q}/coverage.pdf"
         script:
            "scripts/coverage_plot.R"

#### Use Qualimap to get more detailed quality metrics that are compiled into a report. 
Of particular interest is **Page 6 of each report** that compares coverage across the reference (top graph) to %GC content across the reference (smaller bottom graph). From this plot we can conclude there is **no obvious correlation between coverage and sequence content of the reference.**

    rule qualimap:
         input:
            "results/mapped/q{q}/hiv.sorted.dedup.bam"
         output:
            directory("results/mapped/q{q}/qualimap")
         shell:
            "unset DISPLAY | qualimap bamqc -bam {input} -outdir {output} -outfile correlation.pdf -outformat PDF"



---
# brown-ccv-gds-summer-2022

Thank you for taking the time to complete this programming assignment. Through this exercise, we seek to get an insight into:
* your technical skills
* approach to problem solving
* software development practices

Members of our group come from very diverse backgrounds. We understand that methodologies vary greatly depending on your background. While we provide some guidance on technology and approach, you are welcome to use the approach and technology that you are most comfortable with and gives you a fair opportunity to complete the assignment and show us your best work.

If completing this assignment would be an undue burden, please reach out and we will work with you to find another way to assess your technical experience.

## Tasks to be completed

For this assignment, you will create a simple pipeline that calculates the coverage of an Illumina MiSeq data set against a reference sequence after alignment using a tool such as BWA, and tests for correlation between coverage and sequence content of the reference. The choice of technologies, metrics and visualizations are design choices that we are pourposely leaving up to you. However, feel free to reach out if you have questions. Below are some things we like, which may help you guide your choices:

* We are fans of well formatted code, comments, types, modularity
* We are fans of interactive visualizations
* We are fans of a good README.md
* We are fans of conventional commits

## Deliverables
* Source code. We will share a starter repository containing this README with you. Please commit all code (no build files please!) to this repo.
* Updated README.md with explanations about how to run your code and an overview of the application and any major design decisions you made.
* Demonstration of results of working application.

Please try your best. We'll evaluate whatever you provide us, even if your solution is incomplete.

## Time to completion
You have one week to complete the assignment.

## After completion
You will hear from us regarding next steps within 15 days. Continuing candidates will be invited for the next steps in the process.  


