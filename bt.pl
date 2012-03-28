#!/usr/bin/perl 

# use ... dhelp() {{{

use strict;
use warnings;
use File::Basename;
use Getopt::Long;
use LaTeX::BibTeX;

my $this_script=&basename($0);
my $shd=&dirname($0);

# get options{{{
my(%opt,@optstr);
@optstr=( "sect=s",
			"proj=s",
			"infile=s",
			"list=s",
			"startstring=s", 
			"select=s",
	   		"pkey=s"	);
Getopt::Long::Configure(qw(bundling no_getopt_compat no_auto_abbrev no_ignore_case_always));

if ( !@ARGV ){ 
	&dhelp();
	exit 1;
}else{
	GetOptions(\%opt,@optstr);
}
#}}}
#}}}
# subs {{{
# gettime () {{{

sub gettime(){
my @months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
my @weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
my ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
my $year = 1900 + $yearOffset;
my $time = "$hour:$minute:$second, $weekDays[$dayOfWeek] $months[$month] $dayOfMonth, $year";
return $time;
}

#}}}
# dhelp() {{{
sub dhelp(){
print << "HELP";
=========================================================
PURPOSE: 
	Generate targets for a Fortran project
USAGE: 
	$this_script FILE
		FILE is output file with dependencies 
SCRIPT LOCATION:
	$0
=========================================================

HELP
}
#}}}

sub uniq {
# {{{
#   my(@words,%h);
   #%h  = map { $_ => 1 } @_;
   #@words=keys %h;
   #return @words;
    my %h;
    return grep { !$h{$_}++ } @_;
#}}}
}

sub s_uniq{
	return join(&uniq(split $_));
}

sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}
 
# }}}
# vars{{{
my($bibfile,$infile);
my $at_eof;
my (@pkeys,@authors,@auth,@authn,@aF,$y);
my $entry;
# author's surname
my $sname;
# paper key
my $pkey;
my $author;
# hash: author => paper key
my %pkeys_auth;
# hash: author => number of pkeys
my %num_auth;
# myvars - specified as input to the script
my %myvars;

$infile="repdoc.bib";
if (defined($opt{infile})) {$infile=$opt{infile};}
# }}}
# working with the file {{{

$bibfile = new LaTeX::BibTeX::File;
   $bibfile->open ("$infile") || die "$infile: $!\n";

while ($entry = new LaTeX::BibTeX::Entry $bibfile)
   {
    next unless $entry->parse_ok;

	$pkey=$entry->key;
	push(@pkeys,$pkey);
	@auth=$entry->split('author'); 
	foreach my $lauth (@auth){ 
			if ( $lauth =~ m/^\s*(\w+),\s+(.*)/ ){ 
                # SNAME, INITIALS {{{
				$sname=ucfirst(lc($1));
				@aF=split(' ',$lauth);  
				shift @aF;

				foreach(@aF){ 
					s/^\s*([A-Z])\s*\.?\s*([A-Z])\s*\.?\s*([A-Z])\s*\.?/$1. $2. $3./;
					s/^\s*([A-Z])\s*\.?\s*([A-Z])\.?/$1. $2./; 
					s/^\s*([A-Z])\s*\.?\s*$/$1./; 
				}
				$author=$sname.', '.join(' ',@aF);
			}
				##}}}
			else{
				# INITIALS SNAME {{{
				@aF=split(' ',$lauth);  
				# $sname => surname
				$sname=pop @aF;
				$sname=ucfirst(lc($sname));
				foreach(@aF){ 
						s/^\s*([A-Z])\s*\.?\s*([A-Z])\s*\.?\s*([A-Z])\s*\.?/$1. $2. $3./;
						s/^\s*([A-Z])\s*\.?\s*([A-Z])\.?/$1. $2./; 
						s/^\s*([A-Z])\s*\.?\s*$/$1./; 
					}
				$author=$sname.', '.join(' ',@aF);
			#}}}
			}
			$author =~ s/\s*$//g;
			$author =~ s/^\s*//g;
			push(@authn,"$author");

			if (!defined($pkeys_auth{"$author"})){
					$pkeys_auth{"$author"}="$pkey";
					$num_auth{"$author"}=1;
				}else{
					$pkeys_auth{"$author"}="$pkey".' '.$pkeys_auth{"$author"};
					$num_auth{"$author"}++;
			}

	}
			push(@authors,@authn);
	 
      #$entry->write ($newfile);
   }
$at_eof = $bibfile->eof;
$bibfile->close;
#}}}

# formats{{{
my %fmt={ "auth_pkeys" => 1 };


#print $fmt{",cc"}
#}}}

# output{{{

@authors=sort &uniq(@authors);

if (defined($opt{list})){
		if ( $opt{list} =~ /^authors$/ ){
			foreach (@authors){ /^$opt{startstring}/i && print "$_ \n"; }
		}
		elsif ( $opt{list} =~ /^auth_pkeys$/ ){
			foreach my $lauth (@authors){ 
							$lauth=&trim($lauth);	
					if ( $lauth =~ /^$opt{startstring}/i ){
# format {{{
$fmt{"auth_pkeys"}= "format STDOUT = \n"
. '@' . '<' x 30 .' '. '@' . '<' x 5 .' ' x 10 . '@' . '<' x length($pkeys_auth{$lauth}) . "\n"
. '$lauth $num_auth{$lauth} $pkeys_auth{$lauth}' . "\n"
. ".\n";
#  }}}
							eval $fmt{$opt{list}};
						 	write;
					}
			}	
		}
		elsif ( $opt{list} =~ /^pkeys$/ ){
			foreach (@pkeys){ /^$opt{startstring}/i && print "$_\n"; }
		}
}

#}}}

