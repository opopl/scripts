#!/usr/bin/env bash
 
# directory where this script resides
export shd="`dirname $(readlink -f $0)`"
# name of this script 
export this_script=` basename $0 `

vim_opts="-n -p"
v="vim $vim_opts"
repos=( "config" "scripts" "templates" "vrt" "install" "doc-coms" "doc-cit" )

sbdirs(){
# {{{
# main Wales group software directory
export wg_dir="$shd/../../"
packdir=$HOME/arch/packed
unpackdir=$HOME/arch/unpacked
# }}}
}


sbvars(){
# {{{
s_purpose="view source files with vim"
s_project="Wales group svn repository"
s_project="~/scripts"
# }}}
}

sbvars

display_help(){
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

[ -z "$*" ] && ( display_help; exit 0 )

main(){
# {{{

case "$1" in
  v) make >& m.log; vi m.log ;;
  c) make clean ;;
  *)
  ;;
esac    # --- end of case ---

# }}}
}

# main part 
# {{{

script_opts=( $* )
sbdirs

while [ ! -z "$1" ]; do
  	case "$1" in
	#{{{
	  	vm) $v $0; exit ;;
		h) display_help $*; exit ;;
	  	*) main $* && exit 0 ;;
	esac
  	shift
        #}}}
done

# }}}
