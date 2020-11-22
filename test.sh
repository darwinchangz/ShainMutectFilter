#!/bin/bash
module load CBC samtools r
cd ~/test
~/Mutect2_GitHub/Mutect2_Filter.sh ~/test/GI-10.funcotator.txt ~/wget/bams/GI-10_T.bam ~/wget/bams/GI-10_N.bam ~/hg19/hg19.fa male