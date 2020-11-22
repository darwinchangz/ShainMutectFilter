#!/bin/bash
helpFunction()
{
  echo ""
  echo "Shain Lab Mutect2 Filter"
  echo ""
  echo "Usage: ./Mutect2_Filter.sh Tumor.funcotator.txt Tumor.bam Normal.bam genome.fa (male/female)"
  echo ""
}

while getopts "h" opt; do
  case $opt in
    h ) helpFunction ; exit 0
    ;;
  esac
done

if [[ (${1: -4} != ".txt") || (${2: -4} != ".bam") || (${3: -4} != ".bam") || (${4: -3} != ".fa" && ${4: -6} != ".fasta") || (${5: -4} != "male" && ${5: -4} != "Male") ]]
	then
		echo "Incorrect file extensions"
		echo ""
		echo "Make sure the order of the files is correct and that the files themselves are correct."
		echo "Also make sure the sex has been entered"
		echo ""
		echo "e.g. ./Mutect2_Filter.sh Tumor.funcotator.txt Tumor.bam Normal.bam genome.fa (male/female)"
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

funcotator_input=$1
tumorbam=$2
normalbam=$3
genome=$4

#Finding directory for script
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#Setting directory to funcotator input location
dir="$( dirname ${funcotator_input} )"
cd $dir

echo "${funcotator_input}"

#Filtering raw Funcotator Output using R script
Rscript "${scriptdir}/Funcotator_Mutect2.R" "${funcotator_input}"

#Creating Sample ID for output names
sampleid="$( cut -d '.' -f 1 <<< "$(basename ${funcotator_input})" )"

echo "${dir}/${sampleid}_SeqContextInput.txt"
echo "${sampleid}"

#Running Mpileup/UV scripts
echo "Counting reads for mutations. This may take some time (several hours) depending on the number of mutations and the size of bams."
perl "${scriptdir}/Mpileup_Normal.pl" "${dir}/${sampleid}_Tumor_SNP.txt" $normalbam $genome  &> /dev/null
perl "${scriptdir}/Mpileup_Tumor.pl" "${dir}/${sampleid}_Tumor_SNP.txt" $tumorbam $genome  &> /dev/null
perl "${scriptdir}/SeqContext.pl" "${dir}/${sampleid}_SeqContextInput.txt" $genome  &> /dev/null

#Combining outputs
Rscript "${scriptdir}/Mpileup_Concat_Tumor_190611.R" "${dir}/${sampleid}_Tumor_SNP.xlsx"

#Filtering output
Rscript "${scriptdir}/Bulk_Filter.R" "${dir}/${sampleid}_Tumor_SNP.xlsx" $5

echo "Output file is ${dir}/${sampleid}_Pass_Filter.xlsx"

