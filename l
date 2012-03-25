#!/usr/bin/env bash

# sbvars() dhelp() {{{

sbvars(){
# {{{
s_purpose="list various stuff"
s_project=" ~/scripts"

# name of this script 
export this_script=` basename $0 `
# directory where this script resides
export shd="`dirname $(readlink -f $0)`"

vim_opts="-n -p"
v="vim $vim_opts"
gitdirs=( "config" "scripts" "templates" "vrt" "install" "coms" "cit" )

ls="ls --color"

# }}}
}

sbvars

dhelp(){
# {{{
# general beginning part {{{
cat << EOF
=============================================
SCRIPT NAME: $this_script 
PROJECT: $s_project
PURPOSE: $s_purpose
USAGE: $this_script [ OPTIONS ] 

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

	-d 	--dir	list directories 
	-s	--scr	list scripts 

	-f S		list files of the type *S*
	--idat		list files *.i.dat

	--cf		list files in a compact way

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
	  --scr) cat $shd/inc/scripts.i.dat ;;
	  -d|--dir) $ls -l | grep '^d' | awk '{ print $NF }';;
	  ft) ;;
	  --idat) find . -name \*.i.dat | sed 's_\.\/__g' ;;
		  #case "$2" in

		#esac
 #l="ls -alF"
 #ldir="ls -l | egrep '^d'"
	  *)
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
