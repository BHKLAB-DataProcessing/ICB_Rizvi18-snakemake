from snakemake.remote.S3 import RemoteProvider as S3RemoteProvider
S3 = S3RemoteProvider(
    access_key_id=config["key"], 
    secret_access_key=config["secret"],
    host=config["host"],
    stay_on_remote=False
)
prefix = config["prefix"]
filename = config["filename"]

rule get_MultiAssayExp:
    input:
        S3.remote(prefix + "processed/CLIN.csv"),
        S3.remote(prefix + "processed/CNA_gene.csv"),
        S3.remote(prefix + "processed/SNV.csv"),
        S3.remote(prefix + "processed/cased_sequenced.csv"),
        S3.remote(prefix + "annotation/Gencode.v40.annotation.RData")
    output:
        S3.remote(prefix + filename)
    resources:
        mem_mb=4000
    shell:
        """
        Rscript -e \
        '
        load(paste0("{prefix}", "annotation/Gencode.v40.annotation.RData"))
        source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/get_MultiAssayExp.R");
        saveRDS(
            get_MultiAssayExp(study = "Rizvi.18", input_dir = paste0("{prefix}", "processed")), 
            "{prefix}{filename}"
        );
        '
        """

rule download_annotation:
    output:
        S3.remote(prefix + "annotation/Gencode.v40.annotation.RData")
    shell:
        """
        wget https://github.com/BHKLAB-Pachyderm/Annotations/blob/master/Gencode.v40.annotation.RData?raw=true -O {prefix}annotation/Gencode.v40.annotation.RData 
        """

rule format_snv:
    input:
        S3.remote(prefix + "download/SNV.txt.gz"),
        S3.remote(prefix + "processed/cased_sequenced.csv")
    output:
        S3.remote(prefix + "processed/SNV.csv")
    resources:
        mem_mb=2000
    shell:
        """
        Rscript scripts/Format_SNV.R \
        {prefix}download \
        {prefix}processed \
        """

# rule format_cna_seg:
#     input:
#         S3.remote(prefix + "processed/cased_sequenced.csv"),
#         S3.remote(prefix + "download/CNA_seg.txt.gz")
#     output:
#         S3.remote(prefix + "processed/CNA_seg.txt")
#     resources:
#         mem_mb=2000
#     shell:
#         """
#         Rscript scripts/Format_CNA_seg.R \
#         {prefix}download \
#         {prefix}processed \
#         """

rule format_cna_gene:
    input:
        S3.remote(prefix + "processed/cased_sequenced.csv"),
        S3.remote(prefix + "download/CNA_gene.txt.gz")
    output:
        S3.remote(prefix + "processed/CNA_gene.csv")
    resources:
        mem_mb=2000
    shell:
        """
        Rscript scripts/Format_CNA_gene.R \
        {prefix}download \
        {prefix}processed \
        """

rule format_clin:
    input:
        S3.remote(prefix + "processed/cased_sequenced.csv"),
        S3.remote(prefix + "download/CLIN.txt")
    output:
        S3.remote(prefix + "processed/CLIN.csv")
    resources:
        mem_mb=2000
    shell:
        """
        Rscript scripts/Format_CLIN.R \
        {prefix}download \
        {prefix}processed \
        """

rule format_cased_sequenced:
    input:
        S3.remote(prefix + "download/CLIN.txt"),
        S3.remote(prefix + "download/CLIN_Samstein.txt")
    output:
        S3.remote(prefix + "processed/cased_sequenced.csv")
    resources:
        mem_mb=2000
    shell:
        """
        Rscript scripts/Format_cased_sequenced.R \
        {prefix}download \
        {prefix}processed \
        """

rule format_downloaded_data:
    input:
        S3.remote(prefix + "download/nsclc_pd1_msk_2018.tar.gz"),
        S3.remote(prefix + "download/tmb_mskcc_2018.tar.gz")
    output:
        S3.remote(prefix + "download/CLIN.txt"),
        S3.remote(prefix + "download/CLIN_Samstein.txt"),
        S3.remote(prefix + "download/SNV.txt.gz"),
        S3.remote(prefix + "download/CNA_gene.txt.gz")
    shell:
        """
        Rscript scripts/format_downloaded_data.R {prefix}download      
        """

rule download_data:
    output:
        S3.remote(prefix + "download/nsclc_pd1_msk_2018.tar.gz"),
        S3.remote(prefix + "download/tmb_mskcc_2018.tar.gz")
    resources:
        mem_mb=2000
    shell:
        """
        wget -O {prefix}download/nsclc_pd1_msk_2018.tar.gz https://cbioportal-datahub.s3.amazonaws.com/nsclc_pd1_msk_2018.tar.gz
        wget -O {prefix}download/tmb_mskcc_2018.tar.gz https://cbioportal-datahub.s3.amazonaws.com/tmb_mskcc_2018.tar.gz
        """ 
