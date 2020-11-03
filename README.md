# ShainMutectFilter
Shain Lab for cSCC Meta Analysis Project

Paper: 

## Usage
### Disclaimer: This procedure does not call indels.
Install the funcotator_dataSources under Pre-packaged Data Sources - https://gatk.broadinstitute.org/hc/en-us/articles/360036364752-Funcotator

v1.6.20190124 was the version used for our Funcotator source

```
$ gatk Funcotator --variant tumor.vcf --reference hg19.fa --ref-version hg19 -- data-sources-path funcotator_dataSources --output tumor.funcotator.txt --output-file-format MAF
$ MML

```

## Dependencies
* perl
* jdk-1.8.0
* gatk-4.1.2.0+
* R-3.6.1+
* samtools-1.7+

while read direc
        do
samplename=$(basename ${direc})
normalbam="$(ls ${direc}Normal/*recal.bam)"
normalbamname="$(samtools view -H ${normalbam} | grep '^@RG' | sed "s/.*SM:\([^\t]*\).*/\1/g" | uniq)"
tumorbam="$(ls ${direc}SCC/*recal.bam)"

echo "#!/bin/bash
module load CBC jdk/1.8.0 r samtools

Rscript ~/Scripts/Funcotator_Mutect2.R "${samplename}.funcotator.txt"
perl ~/Scripts/Mpileup_Normal.pl "${direc}Mutations/${samplename}_Tumor_SNP_MasterMutationList.txt" $normalbam
perl ~/Scripts/Mpileup_Tumor.pl "${direc}Mutations/${samplename}_Tumor_SNP_MasterMutationList.txt" $tumorbam
perl ~/Scripts/SeqContext.pl SeqContextInput.txt
Rscript ~/Scripts/Mpileup_Concat_Tumor_190611.R "${direc}Mutations/${samplename}_Tumor_SNP_MasterMutationList.xlsx"
Rscript ~/Scripts/Bulk_Filter.R "${direc}Mutations/${samplename}_Tumor_SNP_MasterMutationList.xlsx"" > "${samplename}_Mutect2_tumor.sh"
qsub -l vmem=16gb ~/Ji_SCC/scripts/${samplename}_Mutect2_tumor.sh
done < <(ls -d ~/Ji_SCC/AJ-{08..09}/)

if(!require(psych)){install.packages("psych")}
add - genome input for perl scripts, tumor_cellularity, second bulk filter
