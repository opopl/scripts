#!/usr/bin/perl -w

#  This is sync.pl

#  Use the command
#  sync.pl
#  on its own for usage information.

#  This will be your home directory on your base machine. All other
#  machines will be synchronised with this one.
$remote="";

#  This is your home directory on the machine where you're going to use
#  the get and put commands.
$home=$ENV{HOME};

# print "$0\n";
$get=1, $put=1;
$get=1, $put=0 if $0 eq "$home/bin/get" || $0 eq "get";
$get=0, $put=1 if $0 eq "$home/bin/put" || $0 eq "put";

$dryrun=1;
$opts="";
$tunnel="";
$port=0;

&help, exit unless @ARGV;

$dir="";
while ( @ARGV ) {
  $flag=shift;
  &help, exit if $flag eq "--help" || $flag eq "-h";
  $remote=shift, next if $flag eq "--host";
  $get=1, $put=0, next if $flag eq "-g";
  $get=0, $put=1, next if $flag eq "-p";
  $dryrun=0, next if $flag eq "-go";
  $dir=shift, next if $flag eq "-d";
  $opts .= " --exclude ", $opts .= shift, next if $flag eq "-x";
  $opts .= " ", $opts .= shift, next if $flag eq "-o";
  $port=shift, next if $flag eq "--tunnel";
  if ( $dir ) {
    print "Unrecognised option $flag.
(Note that only one file or directory may be transferred at a time.)\n";
    die "Stopped";
  }
  $dir=$flag;
}

#  If the directory is defined by a relative path (no leading slash)
#  prefix with the current directory path
unless ( $dir=~m+^/+ ) {
  $dir="$ENV{PWD}/$dir";
}

#  Remove the $home part, if present
$dir=~s+$home/++;
#  Remove trailing slashes from directory name
$dir=~s+/*$++;

#  Look for standard options in ~/.syncrc
$getopts="";
$putopts="";
if ( -e "$home/.syncrc" ) {
  open(RC,"$home/.syncrc");
  while (<RC>) {
    chomp;
    next if /^\s*$/;
    s/^ +//;
    ($name,$cmnd,$rest)=split (/\s+/,$_,3);
    if ( $name=~/^host$/i && $remote eq "" ) {
      $remote=$cmnd;
    }
    else {
      $name=~s+^~/++;
      if ( $dir=~/^$name/ ) {
        if ($cmnd eq "get") {
	  $getopts.=" $rest";
        }
        elsif ($cmnd eq "put") {
	  $putopts.=" $rest";
        }
        else {
	  die "Syntax error in ~/.syncrc, line $..\nStopped";
        }
      }
    }
  }
  close RC;
}

die "No host specified" if $remote eq "";
if ( $port ) {
  $tunnel="-p $port -oNoHostAuthenticationForLocalhost=yes";
  $remote=~s/\@.*$/\@localhost:/;
}
$remote.=":" if $remote!~/:$/;

#  Separate $dir into path and directory if not a simple name
if ( $dir=~m:/: ) {
  ($base,$dir)=$dir=~m:^(.*)/([^/]+)$:;
}
else {
  $base="";
}

#  $base must not have a trailing slash
if ( $base ) {
  $base=~s+/$++g;
# $base=~s+^/*+/+ unless $tunnel;
}

while ( $put || $get ) {

  if ( $get ) {
    if ( $base ) {
      $source="$remote$base/$dir";
      $dest="$base";
    }
    else {
      $source="$remote$dir";
      $dest=".";
    }
    print "\nFetching files from $source\n";
    $stdopts=$getopts
  }
  elsif ( $put ){
    if ( $base ) {
      $source="$base/$dir";
    }
    else {
      $source=$dir;
    }
    $dest="$remote$base";
    print "\nSending files to $dest\n";
    $stdopts=$putopts
  }

  if ( $dryrun ) {
    $cmnd=qq+rsync -avub -e "ssh $tunnel" --dry-run --exclude-from ~/.rsyncx \\
    $stdopts $opts \\
    $source $dest+;

    print "$cmnd\n";
    system $cmnd;

    print "Proceed? [yN] ";
    $_=<>;
    exit unless /^y/i;
  }

  system qq+rsync -avub -e "ssh $tunnel" --progress --exclude-from ~/.rsyncx \\
    $stdopts $opts \\
    $source $dest+;

  if ( $get ) { $get=0; }
  elsif ( $put ) { $put=0; }

}

sub help{
print q|
Decide which of the machines that you use is to be your "base machine",
i.e. the one that is to hold the definitive copies of your files.

Put sync.pl in your bin directory in every other machine, make it
executable, and make symbolic links:
chmod a+x sync.pl
ln -s sync.pl get
ln -s sync.pl put

Create a file .syncrc in your home directory, with a line specifying
your account on the base machine. For example,
host user@remote.cam.ac.uk
This file can also specify standard options for particular directories
(see below).

Then, on any machine except your base machine, use the command
get <path>
to update the specified directory or file from the base, and
put <path>
to copy back any new and changed files to the base machine. Here <path>
specifies the file to be transferred, or the directory whose contents are
to be transferred.

The path is specified in the usual way, either relative to the current
directory (no leading slash), or as an absolute path. For example,
get ~/papers
will update ~/papers by reference to ~/papers on the base system, while
get new
issued when the current directory is ~/papers, will update just the
subdirectory ~/papers/new.

You also need a file .rsyncx in your home directory on each machine. This
contains a list of patterns specifying files that are not to be
copied (in either direction). My .rsyncx is

*.dvi
*.log
*.xxx
*.blg
*.x
*.aux
*.old
*.bak
*~
*.o
*.mod
*.xx
core

Normally, when you run put or get, you will see a list of files to be
transferred. No transfer will take place unless you respond "y" to the
prompt that follows. This is to avoid inadvertent transfer of stuff that
you don't want to transfer. You can exclude files from transfer either by
adding further patterns to .rsyncx or by specifying exclusion patterns on
command line -- e.g.
get papers -x '\*.ps'
to avoid transferring postscript files. Note that the "*" in the pattern
needs to be both escaped and quoted.

You will need to provide your password on the remote machine twice, once
for the initial dry run and once for the actual transfer. This can be
avoided by setting up RSA authentication.

Other command-line options:

--host user@remote
is another way to specify the remote host.

--tunnel p
Carry out the transfer through an ssh tunnel previously set up on port p.

--help
prints this file.

-go
bypasses the initial "dry run" and can be used if you're confident that no
rubbish will be transferred by mistake.

-o "<options>"
can be used to specify any rsync option.

Options that are always needed for a particular directory can be provided in
the file ~/.syncrc, by specifying the directory name (as a full path)
followed on the same line by "get" or "put" and the required options. In
this case the options must be in the standard rsync form.
For example
~/lectures   get  --exclude SB
~/lectures   get  --backup-dir=lectures/deleted --delete --backup
Options specified with "get" will apply only to get commands, and those with
"put" only to put commands. The same directory may appear in more than one
line, so both of the above lines might appear. The options will apply to any
transfer involving the specified directory or any of its subdirectories.
|;
}

