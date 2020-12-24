#!/bin/bash
helpFunction()
{
  echo ""
  echo "Shain Lab Indels Filter"
  echo ""
  echo "Usage: Rscript ./ShainMutectFilter/scripts/indels/Pindel_Filter.R normal_indel.vcf tumor_indel.vcf"
  echo ""
  echo "gatk Funcotator --variant tumor_indel.vcf --reference hg19.fa --ref-version hg19 -- data-sources-path funcotator_dataSources --output tumor.func_indel.txt --output-file-format MAF"
  echo ""
  echo "./ShainMutectFilter/scripts/indels/Indel_Filter.sh tumor_indel.vcf tumor.func_indel.txt tumor.bam normal.bam genome.fa"
  echo ""
}

while getopts "h" opt; do
  case $opt in
    h ) helpFunction ; exit 0
    ;;
  esac
done

if [[ (${1: -4} != ".vcf") || (${2: -4} != ".txt") || (${3: -4} != ".bam") || (${4: -4} != ".bam") || (${5: -3} != ".fa" && ${5: -6} != ".fasta") ]]
	then
		echo "Incorrect file extensions"
		echo ""
		echo "Make sure the order of the files is correct and that the files themselves are correct."
		echo ""
		echo "e.g. ./ShainMutectFilter/scripts/indels/Indel_Filter.sh tumor_indel.vcf tumor.func_indel.txt tumor.bam normal.pindel.vcf normal.bam genome.fa"
		exit
fi

# Setting abort function
abort()
{
	echo "Error Occurred."
	echo ""
    echo "Exiting script."
    exit 2
}

samtools=$(command -v samtools)
rscript=$(command -v Rscript)
perl=$(command -v perl)

if [ -z $samtools ] ; then
  echo "Can't find Samtools. Check if this tool is installed and in your path"
  echo ""
fi 

if [ -z $rscript ] ; then
  echo "Can't find R. Check if this tool is installed and in your path"
  echo ""
fi 

if [ -z $perl ] ; then
  echo "Can't find perl. Check if this tool is installed and in your path"
  echo ""
fi 

tumorvcf=$1
funcotator_input=$2
tumorbam=$3
normalbam=$4
genome=$5

#Finding directory for script
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#Setting directory to funcotator input location
dir="$( dirname ${funcotator_input} )"
echo $dir
cd $dir

#Creating Sample ID for output names
sampleid="$( cut -d '.' -f 1 <<< "$(basename ${funcotator_input})" )"

#Filtering raw Funcotator Output using R script
Rscript "${scriptdir}/Pindel_Func.R" "${sampleid}.func_indel.txt"

#Running Mpileup/UV scripts
echo "Counting reads for mutations. This may take some time (several hours) depending on the number of mutations and the size of bams."
perl "${scriptdir}/Mpileup_Indel_Normal.pl" "${dir}/${sampleid}_Indels.txt" $normalbam $genome &> /dev/null
perl "${scriptdir}/Mpileup_Indel_Tumor.pl" "${dir}/${sampleid}_Indels.txt" $tumorbam $genome &> /dev/null

#Combining outputs and filtering
Rscript "${scriptdir}/Indel_Filt.R" "${dir}/${sampleid}_Indels.xlsx" $tumorvcf

echo "Output file is ${dir}/${sampleid}_Indels.xlsx"
echo ""
echo "Manually inspect all indels for validation using Pindel_filtered.vcf in IGV (comparing both tumor and normal). Remove all variants present in normal"
echo ""
echo "When done manually inspecting, combine output file for indels with the output file from SNPs to get the final mutation list"

