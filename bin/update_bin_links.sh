#!/bin/bash

#########################################################################
# -- Author: Amos Folarin                                               #
# -- Organisation: KCL/SLaM                                             #
# -- Email: amosfolarin@gmail.com                                       #
#########################################################################

# DESCRIPTION:
# A primative link manager, aggregates a set of file types in a central bin/ for a project
# copy this script into the bin directory and modify by adding find lines for each file type.

#USAGE:
# run from the bin directory
# bash update_bin_links.sh </myroot/path>  


#ARGS:
root_dir=$1  # root dir to start searching with the find command

#------------------------------------------------------------------------
# aggregate links to a bin directory
# add one find for each type of file required in the bin
#------------------------------------------------------------------------

for g in {*.sh,*.SH,*.[rR]} 
do
	echo "creating links here to found ${g} files"
	find ${root_dir} -type f -name ${g} -exec ln -sf {} \;

done
