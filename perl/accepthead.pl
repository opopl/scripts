#!/usr/bin/perl -w
    
eval 'exec /usr/bin/perl -S $0 ${1+"$@"}'
if 0; #$running_under_some_shell

use strict;
use File::Find ();

#here-doc{{{
my %opts;
@ARGV > 0 and getopts('f:', \%opts) and not (keys %opt > 1) or die
+<< "EOF";
PURPOSE: Accept the HEAD >>>>...=== part 
USAGE: $0 [-f file] 

      -f  set the filename
EOF
#}}}

my $file = $opts{f};

my $head="<<<<<<< HEAD";
my $delim="=======";
my $end=">>>>>>>";

# find2perl part {{{
use vars qw/*name *dir *prune/;
*name   = *File::Find::name;
*dir    = *File::Find::dir;
*prune  = *File::Find::prune;

sub wanted;
sub doexec ($@);

use Cwd ();
my $cwd = Cwd::cwd();

#}}}

# wanted doexec {{{
sub wanted {
    /^.*\.(f|f90|F)\z/s &&
    doexec(0, 'grep',"$head",'{}');
}

sub doexec ($@) {
    my $ok = shift;
    my @command = @_; # copy so we don't try to s/// aliases to constants
    for my $word (@command)
        { $word =~ s#{}#$name#g }
    if ($ok) {
        my $old = select(STDOUT);
        $| = 1;
        print "@command";
        select($old);
        return 0 unless <STDIN> =~ /^y/;
    }
    chdir $cwd; #sigh
    system @command;
    chdir $File::Find::dir;
    return !$?;
}
# }}}

sub AcceptHead{
# {{{
local $file=@_[0];

$old = $file;                                                       
$new = "$file.tmp.$$";                                              
$bak = "$file.bak";                                                 

open(OLD, "< $old")         or die "can't open $old: $!";           
open(NEW, "> $new")         or die "can't open $new: $!";           

my $ih=0;
my $id=0;

while(<OLD>){
   /^$head/ && $ih++;
   if ( /^$end/ ) { 
     $id--; $ih--;
   }
   if ( /^$delim/ ) {
     $id++;
   }
   if (( ( $ih > 0 ) and ( $id==0 ) and ( !/^$head/ )) or
   ( ( $ih==0 ) and ( !/^$end/ ) ) ){
     print NEW;
   }
}

close(OLD)                  or die "can't close $old: $!";          
close(NEW)                  or die "can't close $new: $!";          

rename($old, $bak)          or die "can't rename $old to $bak: $!"; 
rename($new, $old)          or die "can't rename $new to $old: $!";
#}}}
}

# find all the conflict files 
File::Find::find({wanted => \&wanted}, '.');
# resolve the conflicts
&AcceptHead($file);
