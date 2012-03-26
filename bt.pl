#!/usr/bin/perl 

# use ... dhelp() {{{

use strict;
use warnings;
use File::Basename;
use Getopt::Long;
use LaTeX::BibTeX;

my $this_script=&basename($0);
my $shd=&dirname($0);
my(%opt,@optstr);

Getopt::Long::Configure(qw(bundling no_getopt_compat no_auto_abbrev no_ignore_case_always));

@optstr=( "sect=s","proj=s","infile=s","list=s" );

if ( !@ARGV ){ 
	&dhelp();
	exit 1;
}else{
	GetOptions(\%opt,@optstr);
}
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
# }}}

# vars{{{
my($bibfile,$infile);
my $at_eof;
my (@pkeys,@authors,$y);
my $entry;

$infile="repdoc.bib";
if (defined($opt{infile})) {$infile=$opt{infile};}
# }}}

# working with the file {{{

$bibfile = new LaTeX::BibTeX::File;
   $bibfile->open ("$infile") || die "$infile: $!\n";

while ($entry = new LaTeX::BibTeX::Entry $bibfile)
   {
      next unless $entry->parse_ok;

	push(@pkeys,$entry->key);
	push(@authors,$entry->split('author')); 
	 
      #$entry->write ($newfile);
   }

if (defined($opt{list})){
		if ( $opt{list} =~ /^authors$/ ){
			foreach (@authors){
				/^a/i && print "$_\n";
			}
		}
		elsif ( $opt{list} =~ /^keys$/ ){
			foreach (@pkeys){
				print "$_\n";
			}
		}
}

$at_eof = $bibfile->eof;

$bibfile->close;
#}}}
