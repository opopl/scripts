#!/usr/bin/env bash

# sbvars() dhelp() {{{

sbvars(){
# {{{
s_purpose=" ... list papers .."
s_project=" ~/wrk/p/"

# name of this script 
export this_script=` basename $0 `
# directory where this script resides
export shd="`dirname $(readlink -f $0)`"
# shell functions file
export fsh="$hm/scripts/f.sh"
# bibliography file with papers 
export bibf="repdoc.bib"

export field="ChemPhys"
export pdir="$hm/doc/papers/$field/"

vim_opts="-n -p"
v="vim $vim_opts"
gitdirs=( "config" "scripts" "templates" "vrt" "install" "coms" "cit" )

# }}}
}

sbvars
source $fsh

dhelp(){
# {{{
# general beginning part {{{
cat << EOF
=============================================
SCRIPT NAME: $this_script 
PROJECT: $s_project
PURPOSE: $s_purpose
USAGE: $this_script [ OPTIONS ] PAPER
	PAPER can be also a substring of the full paper name,
	e.g., 
	$this_script Ande
	will list all available papers which begin with Ande

	OPTIONS:

	============
	General
	============

			display the help message

	vm		v(iew) m(yself), i.e., edit this script
	-g		gvim invocation
	
	============
EOF
# }}}
# actual interesting part {{{
cat << EOF

	a 	all papers 
	ch  ChemPhys papers

DEFAULTS:

	Field:
		$field
	Papers directory:
		$pdir

EOF
# }}}
# final general part {{{
cat << EOF
REMARKS:
AUTHOR: O. Poplavskyy
SCRIPT LOCATION:
	$0
=============================================
EOF
# }}}
# }}}
}

[ -z "$*" ] && ( dhelp; exit 0 )

#}}}

main(){
# read cmd args {{{

while [ ! -z "$1" ]; do 
	case "$1" in
	  a) cd $pdir; ls *.pdf | sed 's/*.pdf$//g' ;;
	  #at) mktex.pl --listpapers ;;
	  at) ls p.*.tex | sed '/^p.\w*\.\w*\.tex/d' | sed 's/^p\.//g; s/\.tex$//g' ;;
	  #ax) perl -ne "/^\@article\{\w*,/" $bibf ;;
	  *) 
	  	pkey=$1
	  	pfiles=( ` find $pdir -name $pkey\*.pdf | sed "s/^.*\///" ` )
	  	find $pdir -name $pkey\*.pdf | sed "s/^.*\///g; s/\.pdf$//g"
	  ;;
	esac    
	shift
done

# }}}
}

# main part 
# {{{

script_opts=( $* )

# read cmd args => main()  {{{
while [ ! -z "$1" ]; do
  	case "$1" in
		  #{{{
	  	vm) $v $0 $hm/scripts/f.sh; exit ;;
		h) dhelp $*; exit ;;
		-g) v="$v -g" ;;
	  	*) main $* && exit 0 ;;
	esac
  	shift
        #}}}
done

# }}}
