package DebugPrint;

####################################################################################################
#
# Package:    DebugPrint
#
# Function:   Provides the command dp, which simply dumps the given variables and lets the program
#             die afterwards. The command dpf prints the output to the file debub.txt in case of
#             large variable contents. Both commands are handy during debugging as they can be
#             faster used than print statements.
#
# Author:     Benjamin Bulheller
#
# Version:    $Revision: 2946 $, $Date: 2008-04-28 17:19:06 +0100 (Mon, 28 Apr 2008) $
#
# Date:       December 2005
#
# Usage:
#
# use DebugPrint;
# 
# dp ($Scalar);
# dp (\@Array);   # arrays and hashes have to be passed as references
# dp (\%Hash);
# dp ($Scalar, \@Array1, \@Array2);
#
# dpf dumps the output into the file debug.txt 
#
# dpf (\@Array);
#
####################################################################################################

use strict;			 # for proper programs
use Data::Dumper;	 # for printing arrays and hashes

$Data::Dumper::Sortkeys = 1;  # sort the hash keys
# $Data::Dumper::Indent = 3;

require Exporter;
our @ISA    = qw( Exporter );
our @EXPORT = qw( dp dpf );

our $OutputFile = "debug.txt";

####################################################################################################


sub dp { # DebugPrint
	my @args = @_;
	my ($Var, $File);

	if ($args[$#args] eq "DumpIntoFile") {   # if it was called by dpf
		open (OUTPUT, ">$OutputFile");        # dump variable into file
		pop @args;                            # remove last element
		$File = 1;
	}
	else {
		open (OUTPUT, ">&STDOUT");            # dump variable to STDOUT
		$File = 0;
	}
	
	while (@args) {
		$Var = shift @args;
	
		print OUTPUT "\n\n";
	
		if (ref $Var) {
			if		($Var =~ m/ARRAY/)  {
				chomp @{$Var};
				print OUTPUT Dumper @{$Var};
		  	}
			elsif ($Var =~ m/HASH/)   { print OUTPUT Dumper %{$Var} }
			elsif ($Var =~ m/SCALAR/) { print OUTPUT Dumper ${$Var} }
			else	{ print "Error determining reference type!\n" }
		}
		else {
			print OUTPUT Dumper $Var;
		}
	
		print OUTPUT "\n";
	
	} # of while (@args)

	close OUTPUT;
	
	if ($File) { die "\nDied happily a controlled death in debug print. Output saved to $OutputFile\n\n" }
			else { die "\nDied happily a controlled death in debug print.\n\n" }
} # of sub dp


sub dpf { # DebugPrintFile, prints to debug.txt
	my @args = @_;

	push @args, "DumpIntoFile";
	dp (@args);
} # of sub dpf

1;
