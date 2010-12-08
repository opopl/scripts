#/bin/bash

echo_s(){ # print the delimiter line {{{

echo "*************************************************************************************"

} # }}}
echo_h(){ # print help message, if a script is invoked with no arguments {{{

echo_s
case "$1" in
  	"vdoc")  # {{{
cat << EOF
SCRIPT NAME: vdoc
PURPOSE: view different documentation
USAGE: vdoc [OPTIONS]
	OPTIONS:
		
EOF
	;;
	# }}}
	"mscp") # {{{
cat << EOF
SCRIPT NAME: mscp
PURPOSE: copy files to/from a remote location,
		through an ssh tunnel, 
		opened in another terminal window 
		(which is previously invoked 
			with the command mssh)
USAGE: mscp [Options]
	where Options can be:
		-s Source - is the source location for a file/directory to be copied
		-t Target - is the target location
		-d Direction - specifies whether we copy to or from the remote machine:
			t 	from local to the remote 
			f	from remote to the local	
		-rm Remote machine - the name for the remote machine:
			venus, leonov, clust
		-un User name:
			op226, 0502790
		-cc Copy command:
			scp
			rsync (for large files)
DEFAULTS: 
	Source 
	Target
	Direction	t
	Remote machine	leonov
	User name	op226
	Copy command    scp	
EOF
	;;
	# }}}
	"dci") # dci - download-compile-install tool {{{
cat << EOF
SCRIPT NAME: dci - download-compile-install tool
USAGE: dci [PROGRAMS]
	PROGRAMS:
	
	--- web	
			elinks	 		- web browser

	--- file managers
			ranger 
			vifm
	--- vim
       			minibufexpl
			taglist	
	--- chemistry
			vmd
	--- science
			gdl		-	 GNU Data Language
	--- dictionaries
			goldendict	-	 Goldendict, 	http://goldendict.org
	--- mine	
			wchf 		-	 Wigner-Crystal-Hartree-Fock program
			elmc 		- 	 Electron-Liquid Monte-Carlo simulations
			hb		- 	 Hofstadter butterfly
		
EOF
		# }}}
		;;
      esac
echo_s

} # }}} 

