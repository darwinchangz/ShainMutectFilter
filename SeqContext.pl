#!/usr/bin/env perl





use strict;


use warnings;





my $input = $ARGV[0];
my $Inputfa = $ARGV[1];





open (LOG2, ">output.txt") || die "Cannot open outputfile";





open (LOG1, "$input") || die "cannot open input file";


<LOG1>;


print LOG2 "Chromosome\tStart\tStop\tType\tRef\tMut\t-1\t0\t+1\tUV\n";


close (LOG2);





while (<LOG1>) {


	chomp;


	my ($Chromosome,$Start,$Stop,$Type,$Ref,$Mut) = split(/\t/);


	open (LOG4, ">>output.txt");


	print LOG4 "$Chromosome\t$Start\t$Stop\t$Type\t$Ref\t$Mut\t";


	close (LOG4);


	


	my $Chr = ">chr" . "$Chromosome" . "\n";


	my $Pos = $Start;


	open (LOG, "$Inputfa") || die "Could not open .fa";


	my $search = 0;


	my $basepairlow = -60;


	my $basepairhigh = 0;


	my $lastseq;


	


	if ((($Ref eq "CC") && ($Mut eq "TT")) || (($Ref eq "GG") && ($Mut eq "AA"))) {


		open (LOG6, ">> output.txt");


		print LOG6 "\t\t\tUV";


		close (LOG6);	


		}


	


	if ((($Ref eq "C") && ($Mut eq "T")) || (($Ref eq "G") && ($Mut eq "A"))){	


	while (<LOG>) {


		if ($search == 1) {


			$basepairlow = $basepairlow + 60;


			$basepairhigh = $basepairhigh + 60;


			if (($Pos > $basepairlow) && ($Pos <= $basepairhigh)) {


				chomp($_);


				my $s = $_;


				my $subPos = $Pos - $basepairlow - 1;


				my $bp = substr $s, $subPos, 1;


				my $FiveprimeBP;


				my $ThreeprimeBP;


				if ($subPos == 0) {


					$FiveprimeBP = substr $lastseq, 59, 1;


					$ThreeprimeBP = substr $s, $subPos+1, 1;


					}				


				if (($subPos > 0) && ($subPos < 59)) {


					$FiveprimeBP = substr $s, $subPos-1, 1;


					$ThreeprimeBP = substr $s, $subPos+1, 1;


					}


				if ($subPos == 59) {


					$FiveprimeBP = substr $s, $subPos-1, 1;


					my $nextline = <LOG>;


					$ThreeprimeBP = substr $nextline, 0, 1;


					}


				


				my $sun;


				if (($Ref eq "C") && (($FiveprimeBP eq "C") || ($FiveprimeBP eq "T"))) {


					$sun = "UV";


					}


				if (($Ref eq "G") && (($ThreeprimeBP eq "G") || ($ThreeprimeBP eq "A"))) {


					$sun = "UV";


					}


					


				open (LOG3, ">> output.txt");


				print LOG3 "$FiveprimeBP\t$bp\t$ThreeprimeBP\t$sun";


				close (LOG3);


				last;


				}


			}


		if ($_ eq $Chr) {


			$search = 1;


			}


		$lastseq = $_;


		}


		}


	close (LOG);


	


	open (LOG5, ">> output.txt");


	print LOG5 "\n";


	close (LOG5);


	}


close (LOG1);








