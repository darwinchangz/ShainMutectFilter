message("Removing columns and rows from Indel Funcotator Output")
args <- commandArgs(TRUE)
FuncIndeltxt <- args[1]
samplename <- sapply(strsplit(basename(FuncIndeltxt),"\\."), "[", 1)
xlsname <- paste(samplename,"_Indels.xlsx",sep="")
txtname <- paste(samplename,"_Indels.txt",sep="")
library("openxlsx")

#Determining Rows to remove VCF Headers
Data_Indel <- read.csv(FuncIndeltxt, sep = "\t", header = F, stringsAsFactors = F, quote = "")
skiprow <- which(Data_Indel[,1] == "Hugo_Symbol")-2

#Reading Funcotator Indel Output
Data_Indel <- read.csv(FuncIndeltxt, sep = "\t", header = F, stringsAsFactors = F, quote = "", skip=skiprow)
Headers <- c("Hugo_Symbol","Chromosome","Start_Position","End_Position","Variant_Classification","Variant_Type","Reference_Allele","Tumor_Seq_Allele2","dbSNP_RS","dbSNP_Val_Status","Genome_Change","Protein_Change","COSMIC_overlapping_mutations")
Data_Indel_Short <- Data_Indel[, which(Data_Indel[2,] %in% Headers)]

#Filtering rows and columns
Data_Indel_noHead <- Data_Indel_Short[-c(1:2),]
Data_Indel_noHead <- Data_Indel_noHead[c(which(Data_Indel_noHead$V10 == "INS" | Data_Indel_noHead$V10 == "DEL")),]
names(Data_Indel_noHead) <- names(Data_Indel_Short)
Data_Indel_Short <- rbind(Data_Indel_Short[c(1:2),], Data_Indel_noHead)
write.xlsx(Data_Indel_Short, xlsname, rowNames = F, colNames = F, keepNA = F, zoom = 100)

#changing inputs into single basepair indels for mpileup preparation
Data_Indel_noHead[,4] <- Data_Indel_noHead[,3]
names(Data_Indel_noHead) <- names(Data_Indel_Short)
Data_Indel_Shorter <- rbind(Data_Indel_Short[1:2,], Data_Indel_noHead)
Data_Indel_Shorter[-c(1,2), 7] <- substr(Data_Indel_Shorter[-c(1,2), 7], 1, 1)
Data_Indel_Shorter[-c(1,2), 8] <- substr(Data_Indel_Shorter[-c(1,2), 8], 1, 1)
write.table(Data_Indel_Shorter, txtname, sep = "\t", row.names = F, col.names = F, quote = F, na = "") 
