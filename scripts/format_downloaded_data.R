# wget -O ~/Documents/ICBCuration/data_source/Rizvi18/nsclc_pd1_msk_2018.tar.gz https://cbioportal-datahub.s3.amazonaws.com/nsclc_pd1_msk_2018.tar.gz
# wget -O ~/Documents/ICBCuration/data_source/Rizvi18/tmb_mskcc_2018.tar.gz https://cbioportal-datahub.s3.amazonaws.com/tmb_mskcc_2018.tar.gz

library(data.table)

args <- commandArgs(trailingOnly = TRUE)
work_dir <- args[1]

untar(file.path(work_dir, 'nsclc_pd1_msk_2018.tar.gz'), exdir=file.path(work_dir))
untar(file.path(work_dir, 'tmb_mskcc_2018.tar.gz'), exdir=file.path(work_dir))

# CLIN.txt CLIN_Samstein.txt
clin <- read.csv(file.path(work_dir, 'nsclc_pd1_msk_2018', 'data_clinical_patient.txt'), stringsAsFactors=FALSE , sep="\t")
colnames(clin) <- clin[4, ]
clin <- clin[-c(1:4), ]

clin_samstein <- read.csv(file.path(work_dir, 'tmb_mskcc_2018', 'data_clinical_patient.txt'), stringsAsFactors=FALSE , sep="\t")
colnames(clin_samstein) <- clin_samstein[4, ]
clin_samstein <- clin_samstein[-c(1:4), ]

write.table( clin , file=file.path(work_dir, 'CLIN.txt') , quote=FALSE , sep="\t" , col.names=TRUE , row.names=FALSE )
write.table( clin_samstein , file=file.path(work_dir, 'CLIN_Samstein.txt') , quote=FALSE , sep="\t" , col.names=TRUE , row.names=FALSE )

# SNV.txt.gz
snv <- read.csv(file.path(work_dir, 'nsclc_pd1_msk_2018', 'data_mutations.txt'), stringsAsFactors=FALSE , sep="\t")
gz <- gzfile(file.path(work_dir, 'SNV.txt.gz'), "w")
write.table( snv , file=gz , quote=FALSE , sep="\t" , col.names=TRUE , row.names=FALSE )
close(gz)

# CNA_gene.txt.gz
cna <- read.csv(file.path(work_dir, 'nsclc_pd1_msk_2018', 'data_cna.txt'), stringsAsFactors=FALSE , sep="\t")
gz <- gzfile(file.path(work_dir, 'CNA_gene.txt.gz'), "w")
write.table( cna , file=gz , quote=FALSE , sep="\t" , col.names=TRUE , row.names=FALSE )
close(gz)

file.remove(file.path(work_dir, 'nsclc_pd1_msk_2018.tar.gz'))
file.remove(file.path(work_dir, 'tmb_mskcc_2018.tar.gz'))
unlink(file.path(work_dir, "nsclc_pd1_msk_2018"), recursive = TRUE)
unlink(file.path(work_dir, "tmb_mskcc_2018"), recursive = TRUE)