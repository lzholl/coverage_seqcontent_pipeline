library(ggplot2)

cov_across_ref <- read.table("results/qualimap/raw_data_qualimapReport/coverage_across_reference.txt", sep='\t', header=TRUE, col.names=c("Position","Coverage"))
nuc_content <- read.table("results/qualimap/raw_data_qualimapReport/mapped_reads_nucleotide_content.txt", sep='\t', header=TRUE, col.names=c("Position","A","C","G","T","N"))
nuc_content$GC <- nuc_content$C + nuc_content$G
merge <- merge(x=cov_across_ref,y=nuc_content[,c("Position","GC")], by="Position", all.x=TRUE)
write.table(merge,"results/cov_versus_gc.tsv", sep='\t', row.names=FALSE)

cov_gc_plot <- ggplot(merge, aes(x=Position, y=GC)) +
               geom_point()
ggsave("results/cov_gc_plot.pdf")
