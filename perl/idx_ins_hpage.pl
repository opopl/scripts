#!/usr/bin/perl 
# use ... dhelp() {{{
use strict;
use warnings;
use File::Basename;

my $this_script=&basename($0);
my $shd=&dirname($0);

if ( !@ARGV ){ 
	&dhelp();
	exit 1;
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
	In an *.idx file (Latex index file), insert |hyperpage statement
	(for the purposes of hyperlinking).
	If the statement is already included, nothing is inserted.
USAGE: 
	$this_script FILE
		FILE is the input *.idx file
SCRIPT LOCATION:
	$0
=========================================================

HELP
}
#}}}
# }}}


my $infile=$ARGV[0];
my $word="hyperpage";
my $chline;

open(INFILE,"<$infile") || warn $!;

while(<INFILE>){
	chomp; 
	next if /^[\t ]*\%/;
	if ( /\|\(?$word/ || /\|\)/ ){
		print "$_\n";
		next;
	};

	m/^[ \t]*(\\indexentry)\{([\t\-\\ \w\{\}\(\)\!\|]*)\}(\{[0-9]*\})$/g;
	if (defined($3)){
		$chline="$1\{$2\|$word\}$3";
		print "$chline\n";
	}
	else{
		print "$_\n";
	}
}

close(INFILE);
