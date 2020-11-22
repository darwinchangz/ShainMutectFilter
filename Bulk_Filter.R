#!/usr/bin/env Rscript
if(("memisc" %in% installed.packages()[,"Package"]) == "FALSE") {
  install.packages("memisc",dependencies=TRUE)
}
suppressMessages(library("rio"))
suppressMessages(library("openxlsx"))
suppressMessages(library("memisc"))

args <- commandArgs(TRUE)
xls <- args[1]
Subject <- args[2]

#Setting working directory
xlsdir <- dirname(xls)
MMLRootFileName <- sapply(strsplit(basename(xls),"_"), "[", 1)
MMLFileName <- paste(MMLRootFileName, "Pass_Filter.xlsx", sep = "_")
setwd(xlsdir)

#Copying excel to final name
invisible(file.copy(xls, MMLFileName, overwrite = T))

#Converting to csv
csv <- sub(".xlsx",".csv", MMLFileName)
suppressMessages(convert(MMLFileName,csv))

#Opening xlsx and csv
Dataxls <- read.xlsx(MMLFileName, colNames = F, rowNames = F)
input = file(csv, open = "r")
Header = readLines(input, 1)
Data <- read.csv(input, stringsAsFactors = F)
close(input)

#Removing gl + mitochondria mutation calls
chrom <- grepl("gl",Data$Chromosome, ignore.case = FALSE)
Data <- Data[c(which(Data$Normal_MAF >= 0 & Data$Tumor_MAF >= 0 & Data$Chromosome != "M" & Data$Chromosome != "MT" & chrom == "FALSE")),]

#Abbreviating Column names
N_Ref <- Data$Normal_Ref
N_Mut <- Data$Normal_Mut
N_Total <- N_Ref+N_Mut
N_MAF <- Data$Normal_MAF
T_Ref <- Data$Tumor_Ref
T_Mut <- Data$Tumor_Mut
T_Total <- T_Ref+T_Mut
T_MAF <- Data$Tumor_MAF

#Calculating Full List median allelic frequency
T_MAF_05 <- T_MAF[c(which(T_MAF > .05 & T_Mut >= 4))]
Med_T <- median(T_MAF_05)

#Noting mutations with 1000genome or dbsnp rs values
ThousandPres <- grepl("by",Data$dbSNP_Val_Status, ignore.case = FALSE)
dbsnp_rs <- Data$dbSNP_RS
dbsnp_rs[is.na(dbsnp_rs)] <- 0
rsid <- ifelse(dbsnp_rs > 0, "TRUE", "FALSE")

#First Filtering step (Filtering Mutations with low MAF/Reads, dbSNP/1000g values with lower MAF's, X/Y chromosome mutations with lower MAF depending on sex)
Data$Call <- suppressWarnings(cases(
  
  "Delete" = T_MAF < .04 | (T_MAF < .05 & (T_Mut < 8 | N_Mut > 0 | rsid == "TRUE")) | (N_Mut >= 2 & T_MAF < Med_T) | (N_MAF > (T_MAF - Med_T/2.5) & N_Mut >= 4) | T_MAF == "NaN" | N_Mut >= 2 | N_MAF == "NaN" | T_MAF < Med_T/2.5 | T_Mut <= 4 | N_Ref <= 3 | N_MAF >= .05  | (N_MAF != 0 & N_MAF < .1 & N_MAF >= (T_MAF - Med_T/2.5)) | (ThousandPres == "TRUE" & (N_Ref <= 20 | (N_Mut >= 1 & N_Ref < (N_Mut*20 + 20)))) | (ThousandPres == "TRUE" & N_Ref > 20 & N_Mut == 0 & T_MAF < Med_T/2.5) | ((Subject == "male" | Subject == "Male") & (Data$Chromosome == "X" | Data$Chromosome == "Y") & Data$Tumor_MAF <= Med_T*8/5) | (rsid == "TRUE" & ((N_Mut >= 1 & T_MAF < Med_T) | T_MAF < Med_T/1.5)),
  
  "PASS" = (T_MAF > .04 & T_MAF < .05 & T_Mut >= 8 & N_Mut == 0 & rsid == "FALSE") | (N_MAF < .05 & (N_MAF <= (T_MAF - Med_T/2.5))) | ((N_MAF < (T_MAF - Med_T) & N_Mut < 5 & ThousandPres == "TRUE" & ((N_Ref > 20 & N_Mut == 0)) | ((N_Mut >= 1 & N_Ref >= (N_Mut*20 + 20))) & T_MAF >= Med_T/2.5)) | (ThousandPres == "FALSE" & (T_MAF >= Med_T/2.5 & ((N_Mut == 0 & N_Ref >= 10) | (N_MAF < .05 & (N_MAF != 0 & N_MAF < (T_MAF - Med_T/2.5))))) | ((N_Ref <= 9 & N_Ref > 2) & ((N_Mut == 0 & T_Mut >= 5 & T_MAF >= Med_T/2.5) | (N_Mut <= 1 & (N_MAF != 0 & N_MAF < (T_MAF - Med_T/2.5)))))),
  
  "Maybe" = TRUE
  
))

#Second Filtering step (Same as above but median is shifted)
T_MAF_05 <- T_MAF[c(which(T_MAF > .05 & T_Mut >= 4 & Data$Call == "PASS"))]
Med_T <- median(T_MAF_05)

Data$Call <- suppressWarnings(cases(
  
  "Delete" = T_MAF < .04 | (T_MAF < .05 & (T_Mut < 8 | N_Mut > 0 | rsid == "TRUE")) | (N_Mut >= 2 & T_MAF < Med_T) | (N_MAF > (T_MAF - Med_T/2.5) & N_Mut >= 4) | T_MAF == "NaN" | N_Mut >= 2 | N_MAF == "NaN" | T_MAF < Med_T/2.5 | T_Mut <= 4 | N_Ref <= 3 | N_MAF >= .05  | (N_MAF != 0 & N_MAF < .1 & N_MAF >= (T_MAF - Med_T/2.5)) | (ThousandPres == "TRUE" & (N_Ref <= 20 | (N_Mut >= 1 & N_Ref < (N_Mut*20 + 20)))) | (ThousandPres == "TRUE" & N_Ref > 20 & N_Mut == 0 & T_MAF < Med_T/2.5) | ((Subject == "female" | Subject == "Female") & Data$Chromosome == "Y") | ((Subject == "male" | Subject == "Male") & (Data$Chromosome == "X" | Data$Chromosome == "Y") & Data$Tumor_MAF <= Med_T*8/5) | (rsid == "TRUE" & ((N_Mut >= 1 & T_MAF < Med_T) | T_MAF < Med_T/1.5)),
  
  "PASS" = (T_MAF > .04 & T_MAF < .05 & T_Mut >= 8 & N_Mut == 0 & rsid == "FALSE") | (N_MAF < .05 & (N_MAF <= (T_MAF - Med_T/2.5))) | ((N_MAF < (T_MAF - Med_T) & N_Mut < 5 & ThousandPres == "TRUE" & ((N_Ref > 20 & N_Mut == 0)) | ((N_Mut >= 1 & N_Ref >= (N_Mut*20 + 20))) & T_MAF >= Med_T/2.5)) | (ThousandPres == "FALSE" & (T_MAF >= Med_T/2.5 & ((N_Mut == 0 & N_Ref >= 10) | (N_MAF < .05 & (N_MAF != 0 & N_MAF < (T_MAF - Med_T/2.5))))) | ((N_Ref <= 9 & N_Ref > 2) & ((N_Mut == 0 & T_Mut >= 5 & T_MAF >= Med_T/2.5) | (N_Mut <= 1 & (N_MAF != 0 & N_MAF < (T_MAF - Med_T/2.5)))))),
  
  "Maybe" = TRUE
  
))



#Calculating proper tumor cellularity based off peak density MAF
DataPASS <- Data[c(which(Data$Call == "PASS")),]
T_MAF_PASS <- DataPASS$Tumor_Mut/(DataPASS$Tumor_Mut+DataPASS$Tumor_Ref)
tumor_cellularity <- 2*density(T_MAF_PASS)$x[which.max(density(T_MAF_PASS)$y)]
print(tumor_cellularity*100)


#Calculating Normalized MAF based off tumor cellularity
Data$Normalized_MAF <- Data$Tumor_MAF/tumor_cellularity
Normalized_MAF <- as.numeric(Data$Normalized_MAF)
Data$Normalized_MAF <- ifelse(Normalized_MAF > 1, 1, Normalized_MAF)

#3rd Filter
Med_T <- tumor_cellularity/2
Data$Call <- suppressWarnings(cases(
  
  "Delete" = T_MAF < .04 | (T_MAF < .05 & (T_Mut < 8 | N_Mut > 0 | rsid == "TRUE")) | (N_Mut >= 2 & T_MAF < Med_T) | (N_MAF > (T_MAF - Med_T/2.5) & N_Mut >= 4) | T_MAF == "NaN" | N_Mut >= 2 | N_MAF == "NaN" | T_MAF < Med_T/2.5 | T_Mut <= 4 | N_Ref <= 3 | N_MAF >= .05  | (N_MAF != 0 & N_MAF < .1 & N_MAF >= (T_MAF - Med_T/2.5)) | (ThousandPres == "TRUE" & (N_Ref <= 20 | (N_Mut >= 1 & N_Ref < (N_Mut*20 + 20)))) | (ThousandPres == "TRUE" & N_Ref > 20 & N_Mut == 0 & T_MAF < Med_T/2.5) | ((Subject == "female" | Subject == "Female") & Data$Chromosome == "Y") | ((Subject == "male" | Subject == "Male") & (Data$Chromosome == "X" | Data$Chromosome == "Y") & Data$Tumor_MAF <= Med_T*8/5) | (rsid == "TRUE" & ((N_Mut >= 1 & T_MAF < Med_T) | T_MAF < Med_T/1.5)),
  
  "PASS" = (T_MAF > .04 & T_MAF < .05 & T_Mut >= 8 & N_Mut == 0 & rsid == "FALSE") | (N_MAF < .05 & (N_MAF <= (T_MAF - Med_T/2.5))) | ((N_MAF < (T_MAF - Med_T) & N_Mut < 5 & ThousandPres == "TRUE" & ((N_Ref > 20 & N_Mut == 0)) | ((N_Mut >= 1 & N_Ref >= (N_Mut*20 + 20))) & T_MAF >= Med_T/2.5)) | (ThousandPres == "FALSE" & (T_MAF >= Med_T/2.5 & ((N_Mut == 0 & N_Ref >= 10) | (N_MAF < .05 & (N_MAF != 0 & N_MAF < (T_MAF - Med_T/2.5))))) | ((N_Ref <= 9 & N_Ref > 2) & ((N_Mut == 0 & T_Mut >= 5 & T_MAF >= Med_T/2.5) | (N_Mut <= 1 & (N_MAF != 0 & N_MAF < (T_MAF - Med_T/2.5)))))),
  
  "Maybe" = TRUE
  
))

#Sorting by decreasing MAF
Data <- Data[order(Data$Tumor_MAF, decreasing = TRUE),]
Data <- Data[c(which(Data$Call != "Delete")),]

#Adding Tumor Cellularity to rightmost column
Data$Tumor_Cellularity <- c(tumor_cellularity*100,rep("",nrow(Data)-1))

#Rounding MAF's to nearest .0001
Data$Normal_MAF <- ifelse(substr(Data$Normal_MAF, 6, 6) == "0", substr(Data$Normal_MAF, 1, 5), substr(Data$Normal_MAF, 1, 6))
Data$Tumor_MAF <- ifelse(substr(Data$Tumor_MAF, 6, 6) == "0", substr(Data$Tumor_MAF, 1, 5), substr(Data$Tumor_MAF, 1, 6))
Data$Normalized_MAF <- ifelse(substr(Data$Normalized_MAF, 6, 6) == "0", substr(Data$Normalized_MAF, 1, 5), substr(Data$Normalized_MAF, 1, 6))
Data$Tumor_Cellularity <- ifelse(substr(Data$Tumor_Cellularity, 6, 6) == "0", substr(Data$Tumor_Cellularity, 1, 5), substr(Data$Tumor_Cellularity, 1, 6))

#Saving csv output
output = file(csv, open = "w")
writeLines(Header, output)
write.csv(Data, output, row.names = F, na = "")
close(output)

#Copying over to excel output
names(Dataxls) <- names(Data)
Dataxls <- rbind(Dataxls[1:2,], Data)
suppressMessages(write.xlsx(Dataxls, MMLFileName, colNames = F, rowNames = F, keepNA = F, zoom = 110))


