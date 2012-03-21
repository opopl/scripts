#!/usr/bin/perl 
# use ... dhelp() {{{
use strict;
use warnings;
use File::Basename;
use Getopt::Long;

my $this_script=&basename($0);
my $shd=&dirname($0);

my(%opt,@optstr);

Getopt::Long::Configure(qw(bundling no_getopt_compat no_auto_abbrev no_ignore_case_always));

@optstr=( "sect=s","proj=s","infile=s" );


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
	In an *.lof file (Latex list-of-figures file), 
	rename references to the figures, so that the hyperlinks are correct 
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

# intro  {{{

my $infile=$opt{infile};
my $chline;
my $pap_num;
my $short_pap_name;
my $pap_name;
# "ms" means "matched string"
my %ms;
# $pf => $ms{pap_fig}, i.e., construction HT92-fig3, for example
my $pf;
my $pf_old;
my $fig_num;

my $sect=$opt{sect};
my $proj=$opt{proj};

#}}}

open(INFILE,"<$infile") || warn $!;

while(<INFILE>){
#{{{
	chomp; 
	#\newlabel{fig:GuoTH92-fig1}{{GuoTH92-fig1}{51}{A schematic energy spectrum of a protein moleculex }{figure.1.1}{}}

	if ( m/^[ \t]*(\\newlabel)\{(fig\:.*?)\}\{\{.*?\}\{([0-9]*)\}\{(.*)\}\{figure\.(.*)\}\{\}\}/ ){
		if (defined($1)){
			# a check...
			# print "$1 $2 $3 $5\n";
			$ms{start}=$1;
			$ms{pap_fig}=$2;
			$ms{page_num}=$3;
			$ms{mid}=$4;
			$ms{old_fig_num}=$5;
			# get pap_name, e.g., HT92 and fig_num ( figure number, e.g., 1 )
			$pap_name=$ms{pap_fig};
			$fig_num=$ms{pap_fig};
			$pap_name =~ s/^fig\://g ;
			$pap_name =~ s/\-fig.*$//g ;
			$fig_num =~ s/^.*\-fig//g ;
			# a check... 
			# print "$ms{pap_fig} $pap_name $fig_num\n";
			#
			chomp $pap_name;
			$pap_num=`pap_num.pl --pkey $pap_name --sect $sect --proj $proj`;
			chomp $pap_num;

			$short_pap_name=` short_pap_key --proj $proj --pkey $pap_name `;
			if ( !$short_pap_name ){
				$short_pap_name=` short_pap_key --proj $proj --pkey $pap_name --m usekdat `;
			}
			chomp $short_pap_name;
			$ms{pap_fig}="$short_pap_name\-fig$fig_num";
			$ms{pap_fig}="$short_pap_name\-fig$fig_num";
			$pf=$ms{pap_fig};
			$pf_old=$ms{pap_fig};
			print "$ms{start}\{fig:$pf_old\}\{\{$pf\}\{$ms{page_num}\}\{$ms{mid}\}\{figure\.$pap_num\.$ms{old_fig_num}\}\{\}\}\n";
			}
		}
	else
		{
		print "$_\n";
		#next;
	}
#}}}
}

close(INFILE);
