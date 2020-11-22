#!/usr/bin/env Rscript
library(ggplot2)
args <- commandArgs(TRUE)
xls <- args[1]
library("rio")
setwd(dirname(xls))
csv <- sub(".xlsx",".csv", xls)
suppressMessages(convert(xls,csv))
xlsname <- sub(".*([A-Z][A-Z]-[0-9]+).*","\\1", xls)
pdfname <- paste(xlsname,"Density_Plot.pdf",sep="_")
input = file(csv, open = "r")
Header = readLines(input, 1)
Data <- read.csv(input, stringsAsFactors = F)
close(input)
DataPASS <- Data[c(which(Data$Call == "PASS")),]
T_MAF <- DataPASS$Tumor_Mut/(DataPASS$Tumor_Mut+DataPASS$Tumor_Ref)
g <- ggplot(data = DataPASS, aes(T_MAF)) + geom_density() + scale_x_continuous(breaks = seq(0,1,by=.05)) + coord_cartesian(xlim = c(0, 1))
print(100*2*density(T_MAF)$x[which.max(density(T_MAF)$y)])

ggsave(pdfname, width = 8, height = 6)
output = file(csv, open = "w")
writeLines(Header, output)
write.csv(Data, output, row.names = F, na = "")
close(output)
