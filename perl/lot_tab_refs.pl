#!/usr/bin/perl 

# use ... dhelp() {{{

use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use Shell qw(cat ps cp);

my(%opt,@optstr);

Getopt::Long::Configure(qw(bundling no_getopt_compat no_auto_abbrev no_ignore_case_always));

my $this_script=&basename($0);
my $shd=&dirname($0);

@optstr=( "sect=s", "pkey=s","proj=s","infile=s" );

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
	In an *.lof file (Latex list-of-tables file), 
	rename references to the tables, so that the hyperlinks are correct 
USAGE: 
	$this_script FILE
		FILE is the input *.lof file
SCRIPT LOCATION:
	$0
=========================================================

HELP
}
#}}}
# }}}


my $infile=$opt{infile};
my $chline;
my $pap_num;
my $short_pap_name;
my $pap_name;
# "ms" means "matched string"
my %ms;
my $tab_num;

my $sect=$opt{sect};
my $proj=$opt{proj};
my $pkey=$opt{pkey};

open(INFILE,"<$infile") || warn $!;

while(<INFILE>){
	#{{{
	chomp; 

	m/^[ \t]*(\\contentsline[ \t]*\{table\}\{\\numberline[ \t]*)\{(.*)\}\{(.*)\}\}\{([0-9]*)\}\{table\.(.*)\}/g;

	if (defined($1)){
		$ms{start}=$1;
		$ms{pap_tab}=$2;
		$ms{mid}=$3;
		$ms{page_num}=$4;
		$ms{old_tab_num}=$5;
		# get pap_name, e.g., HT92 and tab_num (table number, e.g., 1  )
		$pap_name=$ms{pap_tab};
		$tab_num=$ms{pap_tab};
		$pap_name =~ s/\-tab.*$//g ;
		$tab_num =~ s/^.*\-tab//g ;
		# a check... 
		# print "$ms{pap_tab} $pap_name $tab_num\n";
		#
		chomp $pap_name;
		$short_pap_name=` short_pap_key --proj $proj --pkey $pap_name `;
		if ( !$short_pap_name ){
			$short_pap_name=` short_pap_key --proj $proj --pkey $pap_name --m usekdat `;
		}
		$pap_num=` pap_num.pl --sect $sect --proj $proj --pkey $pap_name `;
		chomp $pap_num;
		chomp $short_pap_name;
		#print "$short_pap_name $pap_name\n";
		print "$ms{start}\{$short_pap_name-tab$tab_num\}\{$ms{mid}\}\}\{$ms{page_num}\}\{table.$ms{old_tab_num}\}\n";
	}
	else{
		print "$_\n";
	}
#}}}
}

close(INFILE);
