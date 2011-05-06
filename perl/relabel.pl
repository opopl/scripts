#!/usr/bin/perl

use strict;
use Pod::Usage;
use Getopt::Long;

our ($opt_help, $opt_man);
GetOptions("help", "man")
  or pod2usage("Try '$0 --help' for more information");
pod2usage(-verbose => 1) if $opt_help;
pod2usage(-verbose => 2) if $opt_man;

my $tmp = "/tmp/rel.$$";        # Temporary file name
my $label_no_start = 100;        # First new label number
my $label_no_incr = 10;            # New label increment
my $cont_char = '&';            # Continuation character
my $label_no = $label_no_start;
my $section_no = 0;
my $s_pref = $section_no."_";
my $left;
my $parexp;
my %type;
my %label;
my $lookahead;
#
# get a line, combining continuation lines
#
sub get_line {
    my $thisline = $lookahead;
    line: while ($lookahead = <TMP>) {
        if ($lookahead =~ s/^     \S/     $cont_char/) {
            $thisline .= $lookahead;
        }
        else {
            last line;
        }
    }
    $thisline;
}
#
# Find matching parenthesis
#
sub find_match {
    $parexp = '';
    while (/[()]/) {
        $parexp .= $`;
        $parexp .= $&;
        $_ = $';
        if ($& eq "(") { $left++; }
        else           { $left--; }
        if ($left == 0) { last; }
    }
}
#
# first pass - collect all labels and copy to tmp file
#
open(TMP,">$tmp") || die "Can't open tmp file";
my $no_change_needed = 1;
while (<>) {
#
#    Skip comments
#
    if (/^[!c#*]/i) {
        print TMP;
        next;
    }
#
#    Check for new section (function or subroutine)
#
    if (/function|subroutine/i && $` !~ /'/) {
        $section_no++;
        $s_pref = $section_no."_";
        $label_no = $label_no_start;
    }
#
#    Check for numeric label field
#
    my $label_field = substr($_,0,5);
    if ($label_field =~ s/^[ 0]*([1-9][0-9]*) */$1/) {
        $label_field = $s_pref.$label_field;
        if ($label{$label_field}) {        # Duplicate label
            close(TMP);
            system "rm $tmp";
            die "Duplicate label $label_field";
        }
        if ($label_field != $label_no) {
            $no_change_needed = 0;
        }
        printf TMP ("%5d", $label_no);        # New label
        $_ = substr($_,5,999);
        $label{$label_field} = $label_no;
        $label_no += $label_no_incr;
        if (/^ *format/i) {            # Label type
            $type{$label_field} = "format";
        }
        else {
            $type{$label_field} = "other";
        }
    }
    print TMP;
}
close(TMP);
if ($no_change_needed) {
    system "cat $tmp";
    system "rm $tmp";
    exit 0;
}
#
# Second pass - relabel
#
open(TMP,"$tmp") || die "Can't open tmp file - second pass";
$lookahead = <TMP>;                # Get first line
$section_no = 0;
$s_pref = $section_no."_";
while ($_ = &get_line()) {
#
#    Skip comments
#
    if (/^[c#*]/i) {
        print;
        next;
    }
    s/\t/        /g;            # Replace tabs with blanks
#
#    Check for new section (function or subroutine)
#
    if (/function|subroutine/i && $` !~ /'/) {
        $section_no++;
        $s_pref = $section_no."_";
    }
#
#    Remove and print label field
#    (these were changed during first pass)
#
    print substr($_,0,6);
    $_ = substr($_,6,999);
#
#    Must first skip past `if (...)' constructs
#
    if (/^ *if *\(/i) {
        print $&;
        $_ = $';
        $left = 1;
        find_match();
        if ($left != 0) { die "Illegal if statement"; }
        print $parexp;
    }
#
#    Skip to next line if end-of-line before continuation-line
#
    if (/^ *\n     \S */) {
        print $&;
        $_ = $';
    }
#
#    Do some simple tests to see if line needs further processing
#    (to speed things up)
#
    if ($_ !~ /^ *read|^ *write|^ *print|^ *open|^ *go *to|^ *do/i) {
        print;
        next;
    }
    study;
#
#    Read / write
#
    if (/^ *read *\(|^ *write *\(/i) {
        print $&;
        $_ = $';
        $left = 1;
        find_match();
        if ($left != 0) { die "Illegal read/write statement"; }
        if ($parexp =~ /\n/) {        # Can be removed later
            die "Cannot handle new-lines in r/w statements";
        }
        if ($parexp =~ /^([ \w()*]+ *)/i) {
            print $1;        # unit
            $parexp = $';
        }
        if ($parexp =~ /^(, *\*)/i) {
            print $1;        # free format
            $parexp = $';
        }
        elsif ($parexp =~ /^(, *)([0-9]+)/i) {
            if ($type{$s_pref.$2} ne "format") {
                die "Wrong label type - # $2";
            }
            print $1;
            print $label{$s_pref.$2};    # format number
            $parexp = $';
        }
        while ($parexp =~ /^( *, *[ednr]+ *= *)([0-9]+)/i) {
            if ($type{$s_pref.$2} ne "other") {
                die "Wrong label type - # $2";
            }
            print $1;        # end / err
            print $label{$s_pref.$2};    # label
            $parexp = $';
        }
        print $parexp;
    }
#
#    print
#
    elsif (/^ *print/i) {
        print $&;
        $_ = $';
        if (/^( *)([0-9]+)/i) {
            if ($type{$s_pref.$2} ne "format") {
                die "Wrong label type - # $2";
            }
            print $1;            # space
            print $label{$s_pref.$2};    # label
        }
        $_ = $';
    }
#
#    open
#
    elsif (/^ *open *\(/i) {
        print $&;
        $_ = $';
        $left = 1;
        find_match();
        if ($left != 0) { die "Illegal open statement"; }
        while ($parexp =~ /([ednr]+ *= *)([0-9]+)/i) {
            print $`;
            if ($type{$s_pref.$2} ne "other") {
                die "Wrong label type - # $2";
            }
            print $1;        # end / err
            print $label{$s_pref.$2};    # label
            $parexp = $';
        }
        print $parexp;
    }
#
#    goto
#
    elsif (/^ *go *to */i) {
        print $&;
        $_ = $';
        if (/^([0-9]+) *$/i) {            # only simplest type
            if ($type{$s_pref.$1} ne "other") {
                die "Wrong label type - # $1 sec $section_no";
            }
            print $label{$s_pref.$1};
            $_ = $';
        }
        else { die "Illegal goto"; }
    }
#
#    do
#
    elsif (/^( *do *)([0-9]+)( *\w+ *= *[-+*\/\w() ]+ *, *[-+*\/\w() ]+)/i)
    {
        if ($type{$s_pref.$2} ne "other") {
            die "Wrong label type - # $2";
        }
        print $1;
        print $label{$s_pref.$2};
        print $3;
        $_ = $';
    }
    print;
}
#
# cleanup
#
close(TMP);
system "rm $tmp";
__END__

relabel - Fortran 77 relabeller

=head1 SYNOPSIS

relabel [--help] [--man] [file...] > outfile

=head1 DESCRIPTION

Renumber the Fortran 77 labels in order.

=head1 OPTIONS AND ARGUMENTS

=over 4

=item I<-help>

Print more details about the arguments.

=item I<-man>

Print a full man page.

=back

=head1 RESTRICTIONS

No computed goto.

No assigned goto or assign.

No arithmetic if.

No new-lines inside the parenthesis immediately following a read/write.

Others that I have not thought of.

=head1 AUTHOR

Sverre Froyen
sverre@fesk.seri.gov

Bugfixes and perl 3 support by:
Kate Hedstrom
kate@arsc.edu

=cut
