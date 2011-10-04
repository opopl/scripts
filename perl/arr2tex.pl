#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  arr2tex.pl
#
#        USAGE:  ./arr2tex.pl  
#
#  DESCRIPTION:  
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  YOUR NAME (), 
#      COMPANY:  
#      VERSION:  1.0
#      CREATED:  04/10/11 09:54:29
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;

my($file,@fields);
$file="$ARGV[0]";
open(F,"<$file");

while(<F>){
	chomp;
    @fields = split;
	my $i=0;
	for my $f (@fields) {
		if ( $i < $#fields ){
			print "$f \& ";
		}else{
			print "$f \\\\ \n ";
		}
		$i++;
	}
}
close F;
