#!/usr/bin/perl 

# use ... dhelp() {{{

use strict;
use warnings;

use Getopt::Long;
use File::Basename;
use File::Path qw(mkpath);

my $this_script=&basename($0);
my $shd=&dirname($0);
my(%opt,@optstr);

Getopt::Long::Configure(qw(bundling no_getopt_compat no_auto_abbrev no_ignore_case_always));

@optstr=( "sect=s","pkey=s","proj=s","pnum=i" );

if ( !@ARGV ){ 
	&dhelp();
	exit 1;
}
else{
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
	Give the number of the paper
	rename references to the figures, so that the hyperlinks are correct 
USAGE: 
	$this_script --pkey PAPER_KEY --sect SECT --proj PROJECT --pnum PNUM
EXAMPLE:
	$this_script --pkey HT92 --sect blnall --proj pap 

	The output is 1, since the paper key "HT92" is the first item 
	in the file sects.pap.blnall.i.dat

	If the option --pnum is specified, then 
	instead of retrieving the paper number by using its name, do 
	the inverse task, namely, retrieve the paper's name by 
	using its index. Example:

	$this_script --pnum 1 --sect blnall --proj pap 

	The output is HT92 (see above discussion).

SCRIPT LOCATION:
	$0
=========================================================

HELP
}
#}}}
# }}}

my $sect=$opt{sect};
my $proj=$opt{proj};
my $pkey=$opt{pkey};
my $pnum=$opt{pnum};

my $infile="$proj.sects.$sect.i.dat";
my $n=0;

open(INFILE,"<$infile") || warn $!;

while(<INFILE>){
	chomp; 
	next if m/^[ \t]*#/;
	$n++;
	if (defined($pkey)){ 
				if ( m/^[ \t]*$pkey/ ) { 
					if ( $n gt 0 ) { print "$n\n"; }
					last;
				}
	}
	if ( (defined($pnum)) && ($pnum eq $n) ){ print "$_\n"; last; }
}


close(INFILE);
