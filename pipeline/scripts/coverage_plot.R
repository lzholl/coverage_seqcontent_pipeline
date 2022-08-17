library(ggplot2)

cov <- read.table(snakemake@input[['tsv']], sep='\t', header=FALSE)
cov_fmt <- cov[-c(1)]
colnames(cov_fmt) <- c("position","count")
write.table(cov_fmt, snakemake@output[['tsv']], sep='\t', row.names=FALSE)

cov_plot <- ggplot(cov_fmt, aes(x=position, y=count)) +
           geom_line()
ggsave(snakemake@output[['pdf']], width=12, height=10)
