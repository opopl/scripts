#!/usr/bin/env bash

sbvars(){
# {{{
s_purpose="view scripts"
s_project="~/scripts"
# directory where this script resides
export shd="`dirname $(readlink -f $0)`"
# name of this script 
export this_script=` basename $0 `

vim_opts="-n -p"
v="vim $vim_opts"
repos=( "config" "scripts" "templates" "vrt" "install" "doc-coms" "doc-cit" )

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
	-g		g(raphical) vim  invocation
	
	============
EOF
# }}}
# actual interesting part {{{
cat << EOF

some option

EOF
# }}}
# final general part {{{
cat << EOF
REMARKS:
AUTHOR: O. Poplavskyy
=============================================
EOF
# }}}
# }}}
}

[ -z "$*" ] && ( dhelp; exit 0 )

main(){
# {{{

while [ ! -z "$1" ]; do 
	case "$1" in
	  make|awk) files=( ${files[@]} `find $dir/* ` ) ;;
	  *) files=( ${files[@]} `find $shd -name $1 ` ) ;;
	esac    
	shift
done
	
$v ${files[@]}

# }}}
}

# main part 
# {{{

script_opts=( $* )

while [ ! -z "$1" ]; do
  	case "$1" in
		  #{{{
	  	vm) $v $0; exit ;;
		h) dhelp $*; exit ;;
		-g) v="$v -g" ;;
	  	*) main $* && exit 0 ;;
	esac
  	shift
        #}}}
done

# }}}


