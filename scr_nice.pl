#!/usr/bin/perl 

# use ... dhelp() {{{

use strict;
use warnings;
use File::Basename;
#use File::Inplace;
use File::Copy;
use Getopt::Long;

my $this_script=&basename($0);
my $shd=&dirname($0);
my(%opt,@optstr);

Getopt::Long::Configure(qw(bundling no_getopt_compat no_auto_abbrev no_ignore_case_always));

@optstr=( "sect=s","proj=s","infile=s" );

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

# reading/writing file{{{
# intro  {{{

my $infile=$opt{infile};

#}}}

open(INFILE,"<$infile") || warn $!;
my $fscr = do { local $/;  <INFILE> };
close(INFILE);

# perform changes on fscr {{{
$fscr =~ s/display_help/dhelp/g;
$fscr =~ s/set_base_vars/sbvars/g;
$fscr =~ s/set_base_dirs/sbdirs/g;
# }}}
my @flines= split "\n",$fscr;

open(N,">$infile.new") || warn $!;
copy("$infile","$infile.bak");

foreach my $line (@flines){
	$line =~ s/\r//g;
	print N "$line\n";
}

close(N);
copy("$infile.new","$infile");

##}}}

