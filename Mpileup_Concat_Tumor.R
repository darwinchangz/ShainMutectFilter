#!/usr/bin/env Rscript
args <- commandArgs(TRUE)
MMLxlsx <- args[1]

if(("rio" %in% installed.packages()[,"Package"]) == "FALSE") {
  install.packages("rio",dependencies=TRUE)
}

library(openxlsx)
library(rio)
setwd(dirname(MMLxlsx))

#Transferring Mpileup/UV Outputs to Xlsx
Data_MML <- read.xlsx(MMLxlsx, rowNames = F, colNames = F)
Data_UV <- read.csv("output.txt", sep = "\t", header = F, fill = T, stringsAsFactors = F, quote = "")
Data_MML$X14[2:nrow(Data_MML)] <- c("UV", Data_UV$V10[-1])
Data_Norm <- read.csv("MpileupOutput_Normal.txt", sep = "\t", header = F, fill = T, stringsAsFactors = F, quote = "")
Data_MML$X15[2:nrow(Data_MML)] <- c("Normal_Ref", Data_Norm$V9[-1])
Data_MML$X16[2:nrow(Data_MML)] <- c("Normal_Mut", Data_Norm$V10[-1])
Data_MML$X17[2:nrow(Data_MML)] <- c("Normal_MAF", rep("", nrow(Data_MML)-2))
Data_Tumor <- read.csv("MpileupOutput_Tumor.txt", sep = "\t", header = F, fill = T, stringsAsFactors = F, quote = "")
Data_MML$X18[2:nrow(Data_MML)] <- c("Tumor_Ref", Data_Tumor$V9[-1])
Data_MML$X19[2:nrow(Data_MML)] <- c("Tumor_Mut", Data_Tumor$V10[-1])
Data_MML$X20[2:nrow(Data_MML)] <- c("Tumor_MAF", rep("", nrow(Data_MML)-2))
Data_MML$X21[2:nrow(Data_MML)] <- c("Call", rep("", nrow(Data_MML)-2))
Data_MML$X22[2:nrow(Data_MML)] <- c("Normalized_MAF", rep("", nrow(Data_MML)-2))
Data_MML$X23[2:nrow(Data_MML)] <- c("Tumor_Cellularity", rep("", nrow(Data_MML)-2))
write.xlsx(Data_MML, MMLxlsx, rowNames = F, colNames = F, keepNA = F, zoom = 110)

#Converting to csv
csv <- sub(".xlsx",".csv", MMLxlsx)
convert(MMLxlsx,csv)

#Opening csv
input = file(csv, open = "r")
Header = readLines(input, 1)
Data <- read.csv(input, stringsAsFactors = F)
close(input)

#Calculating Variant Allele Frequencies
Data$Normal_MAF <- Data$Normal_Mut/(Data$Normal_Mut+Data$Normal_Ref)
Data$Tumor_MAF <- Data$Tumor_Mut/(Data$Tumor_Mut+Data$Tumor_Ref)

output = file(csv, open = "w")
writeLines(Header, output)
write.csv(Data, output, row.names = F, na = "")
close(output)

#Combining csv with xlsx
names(Data) <- names(Data_MML)
Data_MML <- rbind(Data_MML[1:2,], Data)
write.xlsx(Data_MML, MMLxlsx, colNames = F, rowNames = F, keepNA = F, zoom = 110)