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



