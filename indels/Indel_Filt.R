#!/usr/bin/env Rscript
args <- commandArgs(TRUE)
IndelMML <- args[1]
IndelVCF <- args[2]
library("openxlsx")
Indel_Data_MML <- read.xlsx(IndelMML, rowNames = F, colNames = F)
Data_Indel_Normal <- read.csv("MpileupOutput_Indel_Normal.txt", sep = "\t", header = F, fill = T, stringsAsFactors = F, quote = "")
Data_Indel_Sample <- read.csv("MpileupOutput_Indel_Tumor.txt", sep = "\t", header = F, fill = T, stringsAsFactors = F, quote = "")
Indel_Data_MML$X14[2:nrow(Indel_Data_MML)] <- c("UV", rep(" ", nrow(Indel_Data_MML)-2))
Indel_Data_MML$X15[2:nrow(Indel_Data_MML)] <- c("Ref", Data_Indel_Normal$V9[-1])
Indel_Data_MML$X16[2:nrow(Indel_Data_MML)] <- c("Mut", Data_Indel_Normal$V10[-1])
Indel_Data_MML$X17[2:nrow(Indel_Data_MML)] <- c("Normal_MAF", rep(" ", nrow(Indel_Data_MML)-2))
Indel_Data_MML$X18[2:nrow(Indel_Data_MML)] <- c("Ref", Data_Indel_Sample$V9[-1])
Indel_Data_MML$X19[2:nrow(Indel_Data_MML)] <- c("Mut", Data_Indel_Sample$V10[-1])
Indel_Data_MML$X20[2:nrow(Indel_Data_MML)] <- c("Tumor_MAF", rep(" ", nrow(Indel_Data_MML)-2))


Indel_Data_MML_noHead <- Indel_Data_MML[3:nrow(Indel_Data_MML),]
Indel_Data_MML_noHead$X3 <- as.numeric(Indel_Data_MML_noHead$X3)
Indel_Data_MML_noHead$X4 <- as.numeric(Indel_Data_MML_noHead$X4)
Indel_Data_MML_noHead$X15 <- as.numeric(Indel_Data_MML_noHead$X15)
Indel_Data_MML_noHead$X16 <- as.numeric(Indel_Data_MML_noHead$X16)
Indel_Data_MML_noHead$X17 <- Indel_Data_MML_noHead$X16/(Indel_Data_MML_noHead$X15+Indel_Data_MML_noHead$X16)
Indel_Data_MML_noHead$X18 <- as.numeric(Indel_Data_MML_noHead$X18)
Indel_Data_MML_noHead$X19 <- as.numeric(Indel_Data_MML_noHead$X19)
Indel_Data_MML_noHead <- Indel_Data_MML_noHead[c(which(Indel_Data_MML_noHead$X17 == 0 & Indel_Data_MML_noHead$X15 >= 10 & ((Indel_Data_MML_noHead$X19 >= 1 & Indel_Data_MML_noHead$X20 > .05) | (nchar(Indel_Data_MML_noHead$X7 == 1) & (nchar(Indel_Data_MML_noHead$X8) <= 1))))),]
Indel_Data_MML_noHead$X18 <- ifelse(Indel_Data_MML_noHead$X6 == "INS", Indel_Data_MML_noHead$X18-Indel_Data_MML_noHead$X19, Indel_Data_MML_noHead$X18)
Indel_Data_MML_noHead$X20 <- Indel_Data_MML_noHead$X19/(Indel_Data_MML_noHead$X18+Indel_Data_MML_noHead$X19)
Indel_Data_MML_noHead$X20 <- ifelse(substr(Indel_Data_MML_noHead$X20, 6, 6) == "0", substr(Indel_Data_MML_noHead$X20, 1, 5), substr(Indel_Data_MML_noHead$X20, 1, 6))

if (nrow(Indel_Data_MML_noHead) > 0){
  library("vcfR")
  library("memisc")
  library("R.utils")
  VCF_indel_data <- read.vcfR(IndelVCF)
  Indel_Data <- getFIX(VCF_indel_data, getINFO = T)
  Indel_Data_MML_noHead_Filt <- Indel_Data_MML_noHead[,c(2,3)]
  Indel_Data_MML_noHead_Filt$X2 <- as.character(paste("chr", Indel_Data_MML_noHead_Filt$X2, sep=""))
  Indel_Data_MML_noHead_Filt$X3 <- as.character(Indel_Data_MML_noHead_Filt$X3)
  Indel_Data_Short <- as.data.frame(Indel_Data[(1:nrow(Indel_Data_MML_noHead_Filt)),])
  if (nrow(Indel_Data_MML_noHead_Filt) == 1) {
    Indel_Data_Short <- as.data.frame(t(Indel_Data_Short))
  }
  Indel_Data_Short$CHROM <- Indel_Data_MML_noHead_Filt$X2
  Indel_Data_Short$POS <- Indel_Data_MML_noHead_Filt$X3
  VCF_indel_data@gt <- as.matrix(VCF_indel_data@gt[c(1:nrow(Indel_Data_MML_noHead_Filt)),])
  if (nrow(Indel_Data_MML_noHead_Filt) == 1) {
    VCF_indel_data@gt <- as.matrix(t(VCF_indel_data@gt))
  }
  VCF_indel_data@fix <- as.matrix(Indel_Data_Short)
  write.vcf(VCF_indel_data, file = "Pindel_filtered.vcf.gz")
  gunzip("Pindel_filtered.vcf.gz", remove = F,overwrite = T)
  file.remove("Pindel_filtered.vcf.gz")
  names(Indel_Data_MML_noHead) <- names(Indel_Data_MML)
  Indel_Data_MML <- rbind(Indel_Data_MML[c(1:2),], Indel_Data_MML_noHead)
  Indel_Data_MML <- Indel_Data_MML[,c(1:20)]
  write.xlsx(Indel_Data_MML, IndelMML, colNames = F, rowNames = F, keepNA = F, zoom = 110)
} else {
  message("No Unique Indels Found")
  names(Indel_Data_MML_noHead) <- names(Indel_Data_MML)
  Indel_Data_MML <- rbind(Indel_Data_MML[c(1:2),], Indel_Data_MML_noHead)
  Indel_Data_MML <- Indel_Data_MML[,c(1:20)]
  write.xlsx(Indel_Data_MML, IndelMML, colNames = F, rowNames = F, keepNA = F, zoom = 110)
  
}

