#/usr/bin/perl -w 

#1{{{
#my $file=$ARGV[0];

#$old = $file;                                                       
#$new = "$file.tmp.$$";                                              
#$bak = "$file.bak";                                                 

#open(OLD, "< $old")         or die "can't open $old: $!";           
#open(NEW, "> $new")         or die "can't open $new: $!";           

## Correct typos, preserving case                                    
#while (<OLD>) {                                                     
#s/\b(p)earl\b/${1}erl/i;                                        
#(print NEW $_)          or die "can't write to $new: $!";       
#}                                                                   

#close(OLD)                  or die "can't close $old: $!";          
#close(NEW)                  or die "can't close $new: $!";          

#rename($old, $bak)          or die "can't rename $old to $bak: $!"; 
#rename($new, $old)          or die "can't rename $new to $old: $!";
#}}}

use Tie::File;

my( $file_name, $arg1, $arg2 ) = @ARGV;

# open the file with tie
tie my @file_lines, 'Tie::File', $file_name or die;

head="<<<<<<< HEAD";
delim="=======";
end=">>>>>>>";

# delete the first line
shift @file_lines;

# filter out lines containing 'sandwich'
@file_lines = grep !/^$arg1,$arg2,/, @file_lines;

# close the file with untie.
# IMPORTANT: always untie when you are done!
untie @file_lines or die "$!";

