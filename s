#!/bin/bash
  
export shd="`dirname $(readlink -f $0)`"
export this_script=` basename $0 `

vim_opts="-n -p"
v="vim $vim_opts"

let screen_num=1
screen_opts=""

dhelp(){
# {{{
cat << EOF
=============================================
SCRIPT NAME: $this_script 
PURPOSE: tool for working with GNU screen
USAGE: $this_script [ OPTIONS ] 
	OPTIONS:
			screen with options:
				$screen_opts
				
		h	display the help message

		d	detach 

		r (x) NUM	reattach to a screen session number NUM
				( NUM can be given by s l - choosing from the list 
			       	of detached (attached) sessions ) 

		k NUM	kill session number NUM. See r (x) option(s)

		l 	list screens
		vm	view me, i.e, view this script

=============================================
EOF
# }}}
}

set_vars(){
#{{{
export socketname=""
export shell="-s bash"
#}}}
}

set_vars
# main part 
# {{{

script_opts=( $* )

aso(){
screen_opts="-r $screen_opts" 
}

case "$1" in
  	"h") dhelp ;;
	"vm") $v $shd/$this_script;;
	"") screen -s bash;;
	*) 
while [ ! -z "$1" ]; do
  	case "$1" in
	  # {{{
	  	d) screen -d ;;
		-S) [ ! -z "$2" ] && socketname="$1 $2" ;;
		-s) [ ! -z "$2" ] && shell="$1 $2" ;;
	  	"r" | "x" | "k" ) 
			case "$1" in
			  	d) aso "-d" ;;
			  	r) screen_opts="-r $screen_opts" ;;
				x) screen_opts="-x $screen_opts" ;;
				k) screen_opts=" $screen_opts -X -S"; screencom="kill" ;;
			esac

			[ ! -z $2 ] && let screen_num=$2

			screen_title=` $0 l | awk "NR==$screen_num" | awk '{ print $2 }' `
			screen $screen_opts $screen_title $screencom
			;;
		"l") screen -list \
			| sed '/There/d ; /Sockets/d; /^[ ]*$/d' \
			| awk '$0 ~ /Attached/ || $0 ~ /Detached/' \
			| awk '{ print NR , $0}' ;;
	  	*) screen $* $socketname -s bash ;;
	# }}}
	esac
	shift
done
;;
esac
# }}}
