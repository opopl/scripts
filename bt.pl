#!/usr/bin/perl 

# use ... dhelp() {{{
# use ... ; define $this_script; $shd; $pref_eoo {{{

use lib ( "$ENV{PERLLIB}" );
use lib ( "$ENV{HOME}/lib/perl/5.10.1" );
use lib ( "$ENV{HOME}/share/perl/5.10.1" );

use strict;
use warnings;
use File::Basename;
use Getopt::Long;
use LaTeX::BibTeX;

my $this_script=&basename($0);
my $shd=&dirname($0);
my $pref_eoo="$this_script>";

#}}}
# get options{{{
my(%opt,@optstr);
@optstr=( "sect=s",
			"proj=s",
			"infile=s",
			"list=s",
			"startstring=s", 
			"select=s",
	   		"pkey=s",
			"debug",
	   		"author=s",
	   		"title=s",
			"rewrite",
			"list_rmfields",
			"print=s"	);
my $cmdline=join(' ',@ARGV);
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
# eoos() {{{
# script-specific output
sub eoos(){
    print "$pref_eoo @_";
}
# debug printing
sub eood(){
	if ($opt{debug}){
		&eoos("@_");
	}
}
# }}}
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
# declarations {{{
my($bibfile,$bofile,$infile,$outfile);
my $at_eof;
my (@pkeys,@authors,@auth,@authn,@aF,$y);
# current date
my $date;
my $entry;
# author's surname
my $sname;
# paper key
my $pkey;
my $s_pkeys;
# entry type
my $etype;
# input paper key (through --pkey )
my $author;
# hash: author => paper key
my %pkeys_auth;
# selected pkeys, see pkeys_title code
my @sel_pkeys;
# hash:  pkey   => title
my %title_pkey;
# hash:  pkey   => abstract
my %abstract_pkey;
# hash of hashes: fields (abstract, title ...) vs pkey 
my %fields_pkey;
# hash: author => number of pkeys
my %num_auth;
# local variables specific to given entry:
my($title,$vol,$abstract,$year,$pages,$journal,$sauth);
#}}}
# %myvars, $mkey... - specified as input to the script {{{
my %myvars;
my $mkey;
my $mtitle;
my @var_keys=qw( pkey author );
foreach(@var_keys){
	if (defined($opt{$_})){
		$myvars{$_}=$opt{$_};}
}
my $tmpf="tmp.bt.title";

if ( -e $tmpf ){ 
		$myvars{title}=`cat $tmpf`; 
		chomp($myvars{title});
}


if (defined($myvars{pkey})){ 
	$mkey=$myvars{pkey};  
	&eood("Paper key provided: $mkey\n");
}
if (defined($myvars{title})){ 
	$mtitle="$myvars{title}";  
	&eood("Title provided: $mtitle\n");
}

# 	keys in the myvars hash:
# 		pkey - paper key
# }}}
# rmfields - fields to be deleted... {{{
# @rmfields     - remove specific fields in a BibTeX entry, e.g. month={} etc.
my @rmfields=qw( month number owner timestamp numpages eprint url
file issn language doc-delivery-number affiliation journal-iso pmid
subject-category number-of-cited-references 
times-cited unique-id type keywords-plus journal-iso 
Funding-Acknowledgement Funding-Text 
);
# remove fields specific to the individual entry type, e.g.
# some only for article etc...
my %rmfields_type=( "article" => "publisher" );
# @mfields - main fields
my @mfields=qw( journal title author volume year pages abstract );
# }}}
# input/output files  {{{
$infile="repdoc.bib";
$outfile="new.repdoc.bib";
if (defined($opt{infile})) { $infile=$opt{infile};}
# }}}
#}}}
# subs2 {{{ 
# arrange_auth() {{{
sub arrange_auth(){
	@authn=();
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
					$pkeys_auth{"$author"}=&trim("$pkey".' '.$pkeys_auth{$author});
					$num_auth{"$author"}++;
			}

	}
	push(@authors,@authn);
	$fields_pkey{author}{$pkey}=join(' and ',@authn);
}
#}}}
# delete_fields(){{{

sub delete_fields(){
$entry->delete(@rmfields);
	foreach (keys %rmfields_type){	
		if ( m/$etype/i ){ $entry->delete($_); }
	}
}

#}}}
#}}}
# working with the file {{{

# bib input/output files; write a header to output file 
# {{{
$bibfile = new LaTeX::BibTeX::File;
   $bibfile->open ("<$infile") || die "$infile: $!\n";
# bib output file, header {{{
open(BOFILE,">$outfile") || die "$!\n" ;
$date=&gettime();
print BOFILE << "EOF";
% 
% Name of the input file:
%		$infile
% Name of the input (this one) file:
%		$outfile
% Date when generated:  
%		$date
% What script was invoked:
%		$this_script
% Command-line arguments provided to the script:
%		$cmdline
% 
EOF
# }}}
close(BOFILE);

$bofile = new LaTeX::BibTeX::File;
  $bofile->open (">>$outfile") || die "$outfile: $!\n";
#}}}

while ($entry = new LaTeX::BibTeX::Entry $bibfile)
# loop over all entries in the input bib-file {{{
   {
	#parse_ok, pkey etype... {{{

    next unless $entry->parse_ok;
	$pkey=$entry->key;
	$etype=$entry->type;
	#}}}

	push(@pkeys,$pkey);
	@auth=$entry->split('author'); 
	&arrange_auth;

	foreach(@mfields){
		if ( "$_" ne "author" ){
			$fields_pkey{$_}{$pkey}=$entry->get($_);
		}
	}
	# set values for local variables: $sauth, $vol, $title ...  {{{
	$sauth=$fields_pkey{author}{$pkey};
	$abstract=$fields_pkey{abstract}{$pkey};
	$vol=$fields_pkey{volume}{$pkey};
	$year=$fields_pkey{year}{$pkey};
	$title=$fields_pkey{title}{$pkey};
	$pages=$fields_pkey{pages}{$pkey};
	$journal=$fields_pkey{journal}{$pkey};
	# }}}
	# prepare latex entry
	$fields_pkey{paptex}{$pkey}=
		"$sauth, \\emph{$title},\\ $journal\\ \\textbf{$vol},\\ $pages\\ ($year).";
	# delete fields
	&delete_fields;
	
	if (defined($myvars{pkey})){
		if ( $myvars{pkey} =~ /^\s*$pkey\s*$/ ){
			last;
		}
	}
	# writing to the new file 
    $entry->write ($bofile);
#}}}
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
		# --list  {{{
if (defined($opt{list})){
		if ( $opt{list} =~ /^authors$/ ){
			foreach (@authors){ /^$opt{startstring}/i && print "$_ \n"; }
		}
		# auth_pkeys: author & number of keys & keys {{{
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
	#}}}
		elsif ( $opt{list} =~ /^title_pkeys$/ ){
			if (defined($myvars{title})){
				foreach(@pkeys){
					#print "$_ $mtitle\n";
					if ( $fields_pkey{title}{$_} =~ /$mtitle/i ){
						#print "$_ $fields_pkey{title}{$_} $mtitle\n";
						push(@sel_pkeys,$_);
					}
				}
				my $s_pkeys=join(' ',sort(&uniq(@sel_pkeys)));
				print "$s_pkeys\n" if ($s_pkeys);
			}
		}
		elsif ( $opt{list} =~ /^pkeys$/ ){
			foreach (@pkeys){ /^$opt{startstring}/i && print "$_\n"; }
		}
		elsif ( $opt{list} =~ /^pkey_titles$/ ){
			if (defined($myvars{author})){
				&eood("Author is: $myvars{author}\n");
				foreach (@authors){
					my $lauth=&trim($_);	
					if ( $lauth =~ /^$myvars{author}/ ){
							print "$lauth\n";
							print "=" x 100 . "\n";
						foreach(sort(split(' ',$pkeys_auth{$lauth}))){
# format {{{
$fmt{"pkey_titles"}= "format STDOUT = \n"
. '@' . '<' x 20 .' '. '@' . '<' x 200 . "\n"
. '$_ $fields_pkey{title}{$_}' . "\n"
. ".\n";
# }}}
							eval $fmt{$opt{list}};
							write;

						}
							print "=" x 100 . "\n";
					}
				}		
				#@sel_pkeys=sort &uniq(@sel_pkeys);
			}
		}
		exit;
}
		#}}}
	# --pkey	 {{{
	if (defined($mkey)){
		if (defined($opt{print})){
			my $val=$fields_pkey{$opt{print}}{$mkey};
			if(defined($val)){
				print "$val\n";
			}
		}
	}
	# }}}
#}}}
