# Installation 
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

# Installation from Github
BiocManager::install("BioinformaticsFMRP/TCGAbiolinks")

BiocManager::install("SummarizedExperiment")




library(SummarizedExperiment)
library(dplyr)
library(DT)

# You can define a list of samples to query and download providing relative TCGA barcodes. 10 patients

listSamples <- c("TCGA-E9-A1NG-11A-52R-A14M-07","TCGA-BH-A1FC-11A-32R-A13Q-07",
                 "TCGA-A7-A13G-11A-51R-A13Q-07","TCGA-BH-A0DK-11A-13R-A089-07",
                 "TCGA-E9-A1RH-11A-34R-A169-07","TCGA-BH-A0AU-01A-11R-A12P-07",
                 "TCGA-C8-A1HJ-01A-11R-A13Q-07","TCGA-A7-A13D-01A-13R-A12P-07",
                 "TCGA-A2-A0CV-01A-31R-A115-07","TCGA-AQ-A0Y5-01A-11R-A14M-07")

# Query platform Illumina HiSeq with a list of barcode
query <- GDCquery(project = "TCGA-BRCA",
                  data.category = "Gene expression",
                  data.type = "Gene expression quantification",
                  experimental.strategy = "RNA-Seq",
                  platform = "Illumina HiSeq",
                  file.type = "results",
                  barcode = listSamples,
                  legacy = TRUE)

# Download a list of barcodes with platform IlluminaHiSeq_RNASeqV2
GDCdownload(query)

# Prepare expression matrix with geneID in the rows and samples (barcode) in the columns
# rsem.genes.results as values
BRCARnaseqSE <- GDCprepare(query)

BRCAMatrix <- assay(BRCARnaseqSE,"raw_count") # or BRCAMatrix <- assay(BRCARnaseqSE,"raw_count")

# For gene expression if you need to see a boxplot correlation and AAIC plot to define outliers you can run
BRCARnaseq_CorOutliers <- TCGAanalyze_Preprocessing(BRCARnaseqSE)


library(TCGAbiolinks)
dataGE <- dataBRCA[sample(rownames(dataBRCA),10),sample(colnames(dataBRCA),7)]

knitr::kable(dataGE[1:10,2:3], digits = 2,
             caption = "Example of a matrix of gene expression (10 genes in rows and 2 samples in columns)",
             row.names = TRUE)


library(png)
library(grid)
img <- readPNG("PreprocessingOutput.png")
grid.raster(img)



# Classifying gliomas samples with gliomaClassifier
query <- GDCquery(
  project = "TCGA-GBM",
  data.category = "DNA methylation",
  barcode = c("TCGA-06-0122","TCGA-14-1456"),
  platform = "Illumina Human Methylation 27",
  legacy = TRUE
)
GDCdownload(query)
data.hg19 <- GDCprepare(query)

assay(data.hg19)[1:5,1:2]

classification <- gliomaClassifier(data.hg19)


names(classification)
classification$final.classification
classification$model.classifications
classification$model.probabilities


