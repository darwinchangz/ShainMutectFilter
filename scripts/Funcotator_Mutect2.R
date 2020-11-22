#!/usr/bin/env Rscript
args <- commandArgs(TRUE)
FuncMAFtxt <- args[1]

#Checking for openxlsx package, if not present, installing
if(("openxlsx" %in% installed.packages()[,"Package"]) == "FALSE") {
  install.packages("openxlsx",dependencies=TRUE)
}

library(openxlsx)
MMLFilename <- sapply(strsplit(basename(FuncMAFtxt),"\\."), "[", 1)

#Determining Rows to remove VCF Headers
Data_Func <- read.csv(FuncMAFtxt, sep = "\t", header = F, stringsAsFactors = F, quote = "")
skiprow <- which(Data_Func[,1] == "Hugo_Symbol")-2

#Reading Funcotator Output
Data_Func <- read.csv(FuncMAFtxt, sep = "\t", header = F, stringsAsFactors = F, quote = "", skip=skiprow)
Headers <- c("Hugo_Symbol","Chromosome","Start_Position","End_Position","Variant_Classification","Variant_Type","Reference_Allele","Tumor_Seq_Allele2","dbSNP_RS","dbSNP_Val_Status","Genome_Change","Protein_Change","COSMIC_overlapping_mutations")
Data_Func_Short <- Data_Func[, which(Data_Func[2,] %in% Headers)]
#Naming Outputs
MMLSNPxlsx <- paste(MMLFilename, "_Tumor_SNP.xlsx", sep = "")
MMLSNPtxt <- paste(MMLFilename, "_Tumor_SNP.txt", sep = "")

#Xlsx Output
Data_Func_Short_SNP <- Data_Func_Short[c(which(Data_Func_Short$V10 != "DEL" & Data_Func_Short$V10 != "INS")),]
write.xlsx(Data_Func_Short_SNP, MMLSNPxlsx, rowNames = F, colNames = F, keepNA = F, zoom = 110) 

#Output for UV script
DataSeqInput <- Data_Func_Short_SNP[-1,-c(1,6)]
write.table(DataSeqInput, paste(MMLFilename, "SeqContextInput.txt", sep = "_"), sep = "\t", row.names = F, col.names = F, quote = F, na = "")

#Txt Output, Modified to change DNP/MNP's into SNPs for mpileup
Data_Func_Short_SNP[-c(1,2), 4] <- Data_Func_Short_SNP[-c(1,2), 3]
Data_Func_Short_SNP[-c(1,2), 7] <- substr(Data_Func_Short_SNP[-c(1,2), 7], 1, 1)
Data_Func_Short_SNP[-c(1,2), 8] <- substr(Data_Func_Short_SNP[-c(1,2), 8], 1, 1)
write.table(Data_Func_Short_SNP, MMLSNPtxt, sep = "\t", row.names = F, col.names = F, quote = F, na = "")
