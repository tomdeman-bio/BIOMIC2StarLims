#!/usr/bin/perl

# Written by Tom de Man
# 6-3-2014
# Version 1.0


#convert BIOMIC values to STARLIMS format/values
use strict;

#conversion table with BIOMIC values and their Starlims counterparts 
my (%conversion_table) = (
'>1024.000'=>'1025',
'>512.000'=>'513',
'>256.000'=>'257',
'>128.000'=>'129',
'>96.000'=>'97',
'>64.000'=>'65',
'>=64.000'=>'65',
'>32.000'=>'33',
'>=32.000'=>'33',
'>16.000'=>'17',
'>12.000'=>'13',
'>8.000'=>'8.1',
'>=8.000'=>'8.1',
'>4.000'=>'4.1',
'>2.000'=>'2.1',
'<=4.000'=>'3.9',
'<=2.000'=>'1.9',
'<=1.000'=>'0.9',
'<=0.500'=>'0.49',
'<=0.250'=>'0.249',
'<=0.120'=>'0.119',
'<=0.064'=>'0.059',
'<=0.032'=>'0.029',
'<=0.016'=>'0.0149');

#raw CSV BIOMIC plain text file
my $file = shift;
#global values 
my $flag = 0;
my $n;
my @header;

open FILE, "$file";

#create intermediate file for filtering out header rows
open OUT, ">$file.filtered.txt";

while (<FILE>) {
        chomp;
        my @split_list = split(',', $_);
        if ($split_list[0] =~ /SPECIMEN/ && $flag == 0) {
        	print OUT "$_\n";
        	$n = scalar @split_list;
        	$flag = 1;
        }elsif ($split_list[0] =~ /SPECIMEN/ && $flag == 1) {
        	next;
        }else {
        	print OUT "$_\n";
        }
} 
close FILE;
close OUT;

#create final output file
open OUT2, ">$file.reshaped.txt";

open FILE, "$file.filtered.txt";
print OUT2 "Specimen\tDrug\tMIC\n";
Print "you are using Version 1.0\n";
print "----------------------------------\n";
print "You have $n columns in your file\n";
print "----------------------------------\n";

while (<FILE>) {
	chomp;
	my @split_list = split(',', $_);
	for (my $i = 4; $i <= $n; $i++) {
        if ($split_list[$i] =~ /[a-zA-Z]/) {
        	@header = split(',', $_);
        }elsif ($split_list[$i] =~ /^</ || $split_list[$i] =~ /^>/ || $split_list[$i] =~ /^\d/) {
        	#remove all internal spaces
        	$split_list[$i] =~ tr/ //ds;
        	#remove trailing white space
        	$split_list[$i] =~ s/\s+$//;
        	if(exists $conversion_table{$split_list[$i]}) {
        		print OUT2 "$split_list[0]\t$header[$i]\t$conversion_table{$split_list[$i]}\n";
        	}else{
        		print OUT2 "$split_list[0]\t$header[$i]\t$split_list[$i]\n";
        	}
        }
	} 		 
}
close FILE;