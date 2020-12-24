# Shain Lab Indels Filter
## Usage: 
### Disclaimer: Must run pindel (v0.2.5) first on both normal and tumor bams
```
$ Rscript ./ShainMutectFilter/scripts/indels/Pindel_Filter.R normal_indel.vcf tumor_indel.vcf
$ gatk Funcotator --variant tumor_indel.vcf --reference hg19.fa --ref-version hg19 -- data-sources-path funcotator_dataSources --output tumor.func_indel.txt --output-file-format MAF
$ ./ShainMutectFilter/scripts/indels/Indel_Filter.sh tumor_indel.vcf tumor.func_indel.txt tumor.bam normal.bam genome.fa
```
## Dependencies
* perl
* jdk-1.8.0
* gatk-4.1.2.0+
* R-3.6.1+
* samtools-1.7+
* pindel-0.2.5
