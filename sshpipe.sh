#!/bin/bash
# very simple ssh pipe
# Use like this:
# unison-gtk -sshcmd /home/user/bin/sshpipe.sh

intermediate=op226@citadel.ch.cam.ac.uk
ssh $intermediate -C -e none ssh $@

