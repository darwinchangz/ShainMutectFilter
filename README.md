# ShainMutectFilter
Shain Lab for cSCC Meta Analysis Project

Manuscript: https://doi.org/10.1038/s41525-021-00226-4

## Usage
### Disclaimer: This procedure currently only works with bams aligned to the hg19 assembly. To call indels, check out the indels sub-folder.

1. Install GATK (v4.1.2.0) and call mutations using Mutect2
2. Download Funcotator Data Sources (20GB of storage required)

``` 
$ wget ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/funcotator/funcotator_dataSources.v1.6.20190124s.tar.gz --no-check-certificate
$ tar xzf funcotator_dataSources.v1.6.20190124s.tar.gz
```
3. Take Mutect2 tumor.vcf output and annotate using Funcotator
```
$ gatk Funcotator --variant tumor.vcf --reference hg19.fa --ref-version hg19 --data-sources-path funcotator_dataSources --output tumor.funcotator.txt --output-file-format MAF
$ ./ShainMutectFilter/scripts/Mutect2_Filter.sh Tumor.funcotator.txt Tumor.bam Normal.bam genome.fa (male/female)
```

## Dependencies
* perl
* jdk-1.8.0
* gatk-4.1.2.0+
* R-3.6.1+
* samtools-1.7+
