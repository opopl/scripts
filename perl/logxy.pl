#!/usr/bin/perl 

# use {{{
use strict;
use warnings;

use Getopt::Long;
use File::Basename;
use File::Path qw(mkpath);
use Statistics::LineFit;

#}}}
# vars {{{
# declarations {{{
my($infile,$ofile);
my @F;
my(%opt,@optstr);
my(%v);
my(@xval,@yval);
#}}}
# this_script shd {{{
my $this_script=&basename($0);
my $shd=&dirname($0);
# }}}
# %x, %y {{{

my(%x,%y);

%x=( 
	'scale'	=>	"1.0",
	'shift'	=>	"0.0",
	'col'	=> 	1,
	'abs'	=> 	1,
	'log'	=> 	1
);

%y=( 
	'scale'	=>	"1.0",
	'shift'	=>	"0.0",
	'col'	=>  2,
	'abs'	=>  1,
	'log'	=> 	1
);
for my $k (keys %x ){
	$opt{"x$k"}=$x{$k};
	$opt{"y$k"}=$y{$k};
}
# }}}
# }}}

# invoke GetOptions(); dhelp() {{{

Getopt::Long::Configure(qw(bundling no_getopt_compat no_auto_abbrev no_ignore_case_always));

@optstr=
	( "xshift=f","yshift=f",
			"xscale=f","yscale=f",
			"xabs","yabs",
			"xlog","ylog",
			"xmin=f","xmax=f","ymin=f","ymax=f",
			"ofile=s",
			"xcol=i","ycol=i",
			"infile=s" );

if ( !@ARGV ){ 
	&dhelp();
	exit;
}else{
	GetOptions(\%opt,@optstr);
}

# }}}
# process %opt {{{

for my $k (keys %x ){
	$x{$k}=$opt{"x$k"};
	$y{$k}=$opt{"y$k"};
}
$infile=$opt{infile};
$ofile=$opt{ofile};
# }}}
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
# log10() {{{
sub log10 {
	my $n = shift;
	return log($n)/log(10);
}
#}}}
# dhelp() {{{
sub dhelp(){
print << "HELP";
=========================================================
PURPOSE: 
	Rescale logarithmically input x-y data
USAGE: 
	$this_script [ OPTIONS ].
		OPTIONS - give input file name;
				  various additional options.
				  Output is written to stdout.
OPTIONS:

	--infile FILE input filename; 

	Log() abs()

	--xabs,--yabs    apply abs() to x,y-data column, respectively
						Default:
							x: $x{abs}
							y: $y{abs}
	--xlog,--ylog	 apply log() --//--
						Default:
							x: $x{log}
							y: $y{log}

	Scaling/shifts

	--yscale 	define scale along the y-axis, i.e, y => y/yscale 
					Default: $y{scale}
	--xscale 	define scale along the x-axis, i.e., x => x/xscale
					Default: $x{scale}
	--yshift	define shift along the y-axis, i.e, y => y-yshift
					Default: $y{shift}
	--xshift	define shift along the y-axis, i.e, x => x-xshift
					Default: $x{shift}

SCRIPT LOCATION:
	$0
=========================================================

HELP
}
#}}}

# }}}
# Process the file {{{
open(INFILE,"<$infile") || warn $!;
open(OFILE,">$ofile") || warn $!;

$x{col}--; $y{col}--;

my $time=&gettime();

print OFILE << "head";
# Time: 
#		$time
# Script: 
# 		$0
# Original data file: 
# 		$infile
head

while(<INFILE>){
	chomp; 
	next if /^\s*#.*/;
	@F=split;
	$v{x}=$F[$x{col}];
	$v{y}=$F[$y{col}];
	if ( defined($opt{xmin}) && ( $v{x} < $opt{xmin}  )) { next; }
	if ( defined($opt{ymin}) && ( $v{y} < $opt{ymin}  )) { next; }
	if ( defined($opt{xmax}) && ( $v{x} > $opt{xmax}  )) { next; }
	if ( defined($opt{ymax}) && ( $v{y} > $opt{ymax}  )) { next; }

	$v{x}=($v{x}-$x{shift})/$x{scale};
	$v{y}=($v{y}-$y{shift})/$y{scale};
	if ( $opt{xabs} ) { $v{x}=abs($v{x}); }
	if ( $opt{yabs} ) { $v{y}=abs($v{y}); }
	if ( $opt{xlog} ) { if ( $v{x} > 0.0 ){ $v{x}=log10($v{x}); } else { next; }}
	if ( $opt{ylog} ) { if ( $v{y} > 0.0 ){ $v{y}=log10($v{y}); } else { next; }}
	push(@xval,$v{x});
	push(@yval,$v{y});
	print OFILE "$v{x}	$v{y} \n";
}
close INFILE;
# }}}
# linear fit {{{
my $lineFit = Statistics::LineFit->new();
 $lineFit->setData(\@xval, \@yval) or die "Invalid regression data\n";
 if (defined $lineFit->rSquared() )
 {
     my($intercept, $slope) = $lineFit->coefficients();
	 if (defined $slope) { print OFILE "##Slope=$slope\n"; }
 }

# }}}
close OFILE;
