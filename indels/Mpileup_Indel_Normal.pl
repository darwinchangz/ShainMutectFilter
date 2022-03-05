#!/usr/bin/env perl

use strict;
use warnings;

my $InputVariants = $ARGV[0];
my $InputBam = $ARGV[1];
my $Inputfa = $ARGV[2];

open (LOG1, ">", "MpileupOutput_Indel_Normal.txt");
open (LOG, "$InputVariants") || die "Could not open input file";
<LOG>;
<LOG>;
print LOG1 "Gene\tChr\tStart\tEnd\tRef\tMut\tDepth\tReads\n";
while (<LOG>) {
	my @line = split/\t/;
	my $samtoolsoutput = `samtools mpileup -Bf "$Inputfa" "$InputBam" -r chr"$line[1]":"$line[2]"-"$line[2]"`;
	chomp $samtoolsoutput;
	my @Pileup = split(/\t/,$samtoolsoutput);
	my @tempsubstring = split(//,$Pileup[4]);
	my $Refcounter = 0;
	my $Mutcounter = 0;
	foreach my $a (@tempsubstring) {
		if (($a =~ m/\./) || ($a =~ m/,/)) {
			$Refcounter++;
			}
		if (($a =~ m/\+/i) || ($a =~ m/\*/)) {
			$Mutcounter++;
			}		
		}
	print LOG1 "$line[0]\t$line[1]\t$line[2]\t$line[3]\t$line[6]\t$line[7]\t$Pileup[3]\t$Pileup[4]\t$Refcounter\t$Mutcounter\n";
	}
close (LOG);
close (LOG1);