library(stringr)

args <- commandArgs(trailingOnly = TRUE)
input_dir <- args[1]
output_dir <- args[2]

source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/Get_Response.R")
source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/format_clin_data.R")

clin_original = read.csv( file.path(input_dir, "CLIN.txt"), stringsAsFactors=FALSE , sep="\t" )
selected_cols <- c( "PATIENT_ID","SEX","AGE", "TREATMENT_TYPE", "PFS_MONTHS","PFS_STATUS" , "DURABLE_CLINICAL_BENEFIT" )
clin = cbind( clin_original[ , selected_cols ] , "Lung", NA , NA , NA , NA , NA , NA , NA , NA )
colnames(clin) = c( "patient" , "sex" , "age" , "drug_type" , "t.pfs" ,"pfs" , "response.other.info" , "primary" ,"histo" , "stage" , "os" , "t.os" , "recist", "dna" , "rna" , "response")

clin$drug_type = ifelse( clin$drug_type %in% "Combination" , "Combo" , "PD-1/PD-L1" )
clin$pfs = ifelse(clin$pfs %in% "Progressed" , 1 , 0)
clin$sex = ifelse(clin$sex %in% "Female" , "F" , "M")
clin$response.other.info = ifelse( clin$response.other.info %in% "YES" , "R" , 
							ifelse( clin$response.other.info %in% "NO" , "NR" , NA ) )
							
clin$response = Get_Response( data=clin )

clin$patient = sapply( clin$patient , function(x){ paste( unlist( strsplit( as.character( x ) , "-" , fixed=TRUE )) , collapse=".") })
clin_original$PATIENT_ID <- str_replace_all(clin_original$PATIENT_ID, '-', '.')

case = read.csv( file.path(output_dir, "cased_sequenced.csv"), stringsAsFactors=FALSE , sep=";" )
clin = clin[ clin$patient %in% case$patient , ]
clin$dna[ clin$patient %in% case[ case$snv %in% 1 , ]$patient ] = "tgs"

clin = clin[ , c("patient" , "sex" , "age" , "primary" , "histo" , "stage" , "response.other.info" , "recist" , "response" , "drug_type" , "dna" , "rna" , "t.pfs" , "pfs" , "t.os" , "os" ) ]

clin <- format_clin_data(clin_original, 'PATIENT_ID', selected_cols, clin)

write.table( clin , file=file.path(output_dir, "CLIN.csv") , quote=FALSE , sep=";" , col.names=TRUE , row.names=FALSE )
