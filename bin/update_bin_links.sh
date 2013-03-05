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
# update_bin_links.sh </myroot/path>  

#ARGS:
root_dir=$1  # root dir to start the find from

#------------------------------------------------------------------------
# aggregate links to a bin directory
# add one find for each type of file required in the bin
#------------------------------------------------------------------------
find ${root_dir} -type f -name "*.sh" -exec ln -s {} \;
find ${root_dir} -type f -name "*.[rR]" -exec ln -s {} \;
find ${root_dir} -type f -name "*.R" -exec ln -s {} \;
