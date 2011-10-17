package GetParameters;

####################################################################################################
#
# Package:     GetParameters
#
# Author:      Benjamin Bulheller
#
# Version:     $Revision: 3066 $, $Date: 2008-06-22 21:18:14 +0100 (Sun, 22 Jun 2008) $
#
# Date:        November 2005
#
####################################################################################################

use strict;                          # always use this!!!
use Data::Dumper;                    # for easy printout of arrays and hashes

require Exporter;
our @ISA    = qw( Exporter );
our @EXPORT = qw( GetParameters );


####################################################################################################


sub GetParameters {
	my @Parameters;  # hold the keys of the given Parameter Hash, i.e. all possible defined parameters
	my ($CurPar, $Boolean, $String);
	my ($ParameterHash, $Help, $OptionsHash);
	my (@FileList, $WasGiven);

	
	if (scalar @_ < 3) { # if less than 3 parameters are passed to the sub routine
		print STDERR "\nERROR (GetParameters.pm): The command line parameters or the help message is not defined.\n\n";
		exit 100;
	} # of if (scalar(@_) < 2)
	
	$ParameterHash = shift;  # the definitions of the parameters (that is, which are possible, and what types they are
	$OptionsHash   = shift;  # the hash that is filled with the parsed arguments
	$Help          = shift;  # the help message
	
	# if -h is not defined as a program parameter, use is as help request and check for it 
   if (not $ParameterHash->{h}) {  
		foreach (@ARGV) { # if -h parameters is given, display help screen
			if ($_ =~ m/^-h/) {
				print STDERR $Help;
				exit 101;
			}
		} # of foreach
	}
	
	# display help if no parameter is given at all
	if (not @ARGV) {
		print STDERR $Help;
		exit 102;
	}
	
	# parse the parameters
	until (not @ARGV) {
		$CurPar = shift @ARGV;

		# if the parameters end with =0 or =1
		if ($CurPar =~ m/=[01]$/) {
			# set $Boolean to the last number after the "="
			$Boolean = substr $CurPar, (length $CurPar)-1;
			# remove the =[01]
			$CurPar =~ s/=[01]//;
		}
		else {
			$Boolean = undef;
		}
		
		if ( ($CurPar =~ m/^-/) and ($CurPar !~ m/^-\d/) ) { # if the argument begins with a dash but no number follows
			$CurPar =~ s/^-//;   # remove the leading dash
			
			# the "--" parameter is only used to end list input
			if ($CurPar eq "-") { next }
			
			# if parameter has not been defined in the options hash
			if (not $ParameterHash->{$CurPar}) {
				print STDERR "\nERROR (GetParameters.pm): -$CurPar is not a defined Parameter!\n\n";
				print STDERR $Help;
				exit 103;
			}

			if ($ParameterHash->{$CurPar} =~ m/^switch\*?$/) {
				# if =0 or =1 was given, set the parameter to the chosen value, otherwise the switch is "true"
				if (defined $Boolean) {
					$OptionsHash->{$CurPar} = $Boolean;
					$OptionsHash->{GivenParams}{$CurPar} = $Boolean;
				}
				else {
					$OptionsHash->{$CurPar} = 1;
					$OptionsHash->{GivenParams}{$CurPar} = 1;
				}
			}
			
			elsif ($ParameterHash->{"$CurPar"} =~ m/^(string|integer|real)?list/) {
				# Parameters given via the command line overwrite default parameters. It needs to be checked, whether
				# default array elements had been declared, which will be erased if this parameter is given. On the 
				# other hand, list parameters may also be split, e.g. "prog -l as er ty -f file -l fg cx" would result
				# in a list "l" containing the five given elements. 
				# The parameter's hash entry in $WasGiven will be true, if it had been passed via the command line before,
				# i.e. then existing elements of this array will be kept. If the entry is false, then existing values were
				# given as default parameters and will be erased.

				# delete default values
				if (not $WasGiven->{$CurPar}) { $OptionsHash->{$CurPar} = [] }

				# 'mark' this parameter, so that more elements can be added later without deleting these ones
				$WasGiven->{$CurPar} = 1;  # set this parameter true

				@FileList = ();
				
				# add the arguments following the list parameter to @FileList
				# the -- parameter to end the list input is caught by the two regexes
				until ( (not @ARGV) or ( ($ARGV[0] =~ m/^-/) and ($ARGV[0] !~ m/^-\d/) ) ) {
					$String = shift (@ARGV);                    # until the next parameter appears or ARGV is emty

					if ($ParameterHash->{"$CurPar"} =~ m/^integerlist/) { &CheckInteger ($String, $CurPar) }
					if ($ParameterHash->{"$CurPar"} =~ m/^reallist/)    { &CheckReal    ($String, $CurPar) }

					push @FileList, $String;
				} # of until (($ARGV[0] =~ m/^-/) or (not @ARGV))
				
				push @{$OptionsHash->{$CurPar}}, @FileList;
				push @{$OptionsHash->{GivenParams}{$CurPar}}, @FileList;
			} # of elsif (${$ParameterHash}{$CurPar} eq "list")
			
			elsif ($ParameterHash->{$CurPar} =~ m/^string\*?$/) {
				$String = shift @ARGV; # read the parameter that followed -$CurPar
				$OptionsHash->{$CurPar} = $String;
				$OptionsHash->{GivenParams}{$CurPar} = $String;
			}
			
			elsif ($ParameterHash->{$CurPar} =~ m/^integer\*?$/) {
				$String = shift @ARGV; # read the parameter that followed -$CurPar
				&CheckInteger ($String, $CurPar);
				$OptionsHash->{$CurPar} = $String;
				$OptionsHash->{GivenParams}{$CurPar} = $String;
			}
			
			elsif ($ParameterHash->{$CurPar} =~ m/^real\*?$/) {
				$String = shift @ARGV; # read the parameter that followed -$CurPar
				&CheckReal ($String, $CurPar);
				$OptionsHash->{$CurPar} = $String;
				$OptionsHash->{GivenParams}{$CurPar} = $String;
			}
			
			else { # if the defintion of the parameter type is wrong (that is, not switch, string or list
				print STDERR "\nParameter type \"", $ParameterHash->{"$CurPar"}, "\" illegal.\n";
				print STDERR "Either \"switch\", \"string\" or \"list\" is expected.\n\n";
				exit 104;
			}
		} # if ($CurPar =~ m/^-/)
		
		else { # if the argument does not begin with a dash
			push @{$OptionsHash->{rest}}, $CurPar;
			push @{$OptionsHash->{GivenParams}{rest}}, $CurPar;
		} # of else
		
	} # of until (not @ARGV)
	
	# check for missing mandatory parameters
	foreach $CurPar (keys %{$ParameterHash}) {
		# if the parameter type declaration contains an asterisk
		if ($ParameterHash->{$CurPar} =~ m/\*/) {
			# but the parameter was not given
			if (not defined $OptionsHash->{$CurPar}) {
				print STDERR "\nMandatory parameter $CurPar not given!\n$Help";
				exit 105;
			}
		}
	} # of foreach $CurPar (keys %{$ParameterHash})

	# check for min, max numbers of elements in lists
	foreach $CurPar (keys %{$ParameterHash}) {
		# if the parameter type declaration defines a list
		if ($ParameterHash->{$CurPar} =~ m/(integer|real|string)?list\[(\d+)?(,)?(\d+)?\]/) {
			# save the backreferences of the RegEx
			my $Min   = $2; if (not defined $Min) { $Min = 0 }
			my $Range = $3; # true if a comma was given, false otherwise
			my $Max   = $4; if (not defined $Max) { $Max = 0 }

			my $Size;

			# determine the size of the array in question
			if (defined $OptionsHash->{$CurPar}) {
				$Size = scalar @{$OptionsHash->{$CurPar}};
			}
			else {
				next;
			}
			
			if (not $Range and $Size != $Min) {
				print STDERR "\nParameter -$CurPar requires two options!\n$Help!";
				exit 108;
			}
			
			if ($Size < $Min) {
				print STDERR "\nParameter -$CurPar needs at least $Min options!\n$Help!";
				exit 106;
			}

			if ($Max > 0 and $Size > $Max) {
				print STDERR "\nParameter -$CurPar can have at most $Max options!\n$Help!";
				exit 107;
			}
		}
	} # of foreach $CurPar (keys %{$ParameterHash})

	return 1;
} # of sub GetParameters


sub CheckInteger { # checks whether a given string is an integer number
	my $String = shift;
	my $CurPar = shift;

	if ($String !~ m/^-{0,1}\d+$/) {
		print STDERR "\nERROR (GetParameters.pm): -$CurPar must be an integer!\n\n";
		exit 109;
	}
} # of sub CheckInteger


sub CheckReal { # checks whether a given string is a real number
	my $String = shift;
	my $CurPar = shift;
	
	if ($String !~ m/^-{0,1}\d*\.{0,1}\d+$/) {
		print STDERR "\nERROR (GetParameters.pm): -$CurPar must be a real number!\n\n";
		exit 110;
	}
} # of sub CheckReal


1;
