package ReadLatex;

####################################################################################################
#
# Package:    ReadLatex
#
# Function:   Provides methods for dealing with LaTeX files
#
# Usage:      ReadLatex (file.tex);
#
#             Returns an array with the latex source code, included files via input are considered
#
# Author:     Benjamin Bulheller
#
# Version:    $Revision: 2946 $, $Date: 2008-04-28 17:19:06 +0100 (Mon, 28 Apr 2008) $
#
# Date:       May 2007
#
####################################################################################################

use strict;                          # always use this!!!
use Data::Dumper;                    # for easy printout of arrays and hashes
use FindBin qw/$Bin/;                # sets $Bin to the directory of the script
use lib $Bin;                        # add the script's directory to the library path
use lib "$ENV{HOME}/bin/perllib/";   # adds ~/bin/perllib to the library path
use DebugPrint;                      # handy during debugging

$Data::Dumper::Sortkeys = 1; # sort the hash keys
# $Data::Dumper::Indent = 3;

require Exporter;
our @ISA    = qw( Exporter );
our @EXPORT = qw( ReadLatex );

####################################################################################################
	
sub ReadLatex { # reads in a LaTeX source code and deals with include directives
	my $File = shift;
	my (@Content, @Source, $InputFile, @Input, $Line);

	if (not -f $File) {
		if (-f "$File.tex") {
			$File = $File . ".tex";
		}
		else {
			print STDERR "ERROR (ReadLatex): File $File could not be found!\n\n";
			exit 100;
		}
	}
	
	open FILE, "<$File";
	@Content = <FILE>;
	close FILE;
	
	while (@Content) {
		$Line = shift @Content;
		
		if ($Line =~ m/\\input(\s+)?\{[\w.\/]+\}/) {
			$InputFile = $Line;
			
			# cut away everything till after "input"
			$InputFile = substr $InputFile, index ($InputFile, "input") + 5;
			# cut away everything till after the next "{"
			$InputFile = substr $InputFile, index ($InputFile, "{") + 1;
			# take only everything between char 0 and the next "}"
			$InputFile = substr $InputFile, 0, index ($InputFile, "}");
			
			# if there is an \input{filename} command, cut out the filename
			# $InputFile =~ s/^.*\\input(\s+)?\{([\w\.\/]+)\}.*$/$2/;
			
			if ($InputFile) {
				# check whether the extension has to be added
				if (-f "$InputFile.tex") { $InputFile = $InputFile . ".tex" }
				
				if (not -f $InputFile) {
					print "WARNING (ReadLatex): input file $InputFile not found!\n";
				}
				else {
					open FILE, "<$InputFile";
					@Input = <FILE>;
					close FILE;
					
					unshift @Content, @Input;
					next;
				}
			}
		}
		
		push @Source, $Line;
	}
	
	return @Source;
} # of sub ReadLatex


1;
