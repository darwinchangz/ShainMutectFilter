#!/usr/bin/env Rscript
message("Filtering Indels present in Normal from pindel_indel.vcf's")
args <- commandArgs(TRUE)
VCF_indel_base_file <- args[1]
IndelVCF <- args[2]
#creating output name via string split of 2nd input
filename <- sapply(strsplit(basename(IndelVCF),"\\."), "[", 1)
vcfname <- paste(filename, "func_input.vcf.gz",sep="_")

options(warn = 2)

#checking packages
if(("vcfR" %in% installed.packages()[,"Package"]) == "FALSE") {
  install.packages("vcfR",dependencies=TRUE)
}
if(("memisc" %in% installed.packages()[,"Package"]) == "FALSE") {
  install.packages("memisc",dependencies=TRUE)
}
if(("R.utils" %in% installed.packages()[,"Package"]) == "FALSE") {
  install.packages("R.utils",dependencies=TRUE)
}

library("vcfR")
library("memisc")
library("R.utils")
VCF_indel_base <- read.vcfR(VCF_indel_base_file)
Indel_Base <- getFIX(VCF_indel_base, getINFO = T)
VCF_indel_data <- read.vcfR(IndelVCF)
Indel_Data <- getFIX(VCF_indel_data, getINFO = T)
Indel_Pres <- Indel_Data[,8] %in% Indel_Base[,8]
Indel_Data_Filt <- Indel_Data[Indel_Pres == "FALSE",]
VCF_indel_data@gt <- VCF_indel_data@gt[Indel_Pres == "FALSE",]
if (class(Indel_Data_Filt) == "character"){
  write.vcf(VCF_indel_data, file = vcfname)
  gunzip(vcfname, remove = F)
  file.remove(vcfname)
} else if (nrow(Indel_Data_Filt) == 0) {
  message("No Unique Indels Found")

} else {
  VCF_indel_data@fix <- Indel_Data_Filt
  VCF_indel_data@fix <- as.matrix(Indel_Data_Filt)
  write.vcf(VCF_indel_data, file = vcfname)
  gunzip(vcfname, remove = F)
  file.remove(vcfname)
}

