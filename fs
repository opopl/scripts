#!/bin/bash
 
# directory where this script resides
export shd="`dirname $(readlink -f $0)`"
# name of this script 
export this_script=` basename $0 `

vim_opts="-n -p"
v="vim $vim_opts"

define_base_dirs(){
# {{{
# main Wales group software directory
export wg_dir="$shd/../../"
packdir=$HOME/arch/packed
unpackdir=$HOME/arch/unpacked
# }}}
}

display_help(){
# {{{
cat << EOF
=============================================
SCRIPT NAME: $this_script 
PROJECT: ~/scripts
PURPOSE: deal with file systems
USAGE: $this_script [ HOST COMMAND ] 

	OPTIONS:

	============
	General
	============

			display the help message

	vm		v(iew) m(yself), i.e., edit this script
	
	============

	HOST(S):

	mq => mek-quake
	cl => clust

	COMMAND(S):

	mnt - mount to /scratch/\$USER/\$host

REMARKS:
AUTHOR: O. Poplavskyy
=============================================
EOF
# }}}
}

[ -z $* ] && ( display_help; exit 0 )

main(){
# {{{

mkdir -p /scratch/op226/$host
tdir="/scratch/op226/$hdir"

case "$1" in
  "mq") host="mek-quake" ; hdir="mq" ;;
  "cl") host="clust" ; hdir="clust" ;;
  "www") host="www-wales.ch.private.cam.ac.uk" ; hdir="www" ;;
  "mnt") sshfs op226@$host:/home/op226 $tdir; cd $tdir ;;
  *)
  ;;
esac    # --- end of case ---
  	

# }}}
}

# main part 
# {{{

script_opts=( $* )
define_base_dirs

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


