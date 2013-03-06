#!/bin/bash

#########################################################################
# -- Author: Amos Folarin                                               #
# -- Organisation: KCL/SLaM                                             #
# -- Email: amosfolarin@gmail.com                                       #
#########################################################################



#------------------------------------------------------------------------
# Build the TFAM file from a Opticall *.calls file
# TFAM FORMAT: Family ID, Individual ID, Paternal ID, Maternal ID, Sex (1=male; 2=female; other=unknown), Phenotype
# e.g.  8129773134_R05C01 8129773134_R05C01 0 0 -9 -9
# TODO: Will need someway to pass in the sex and phenotype currently set to -9
# 
#------------------------------------------------------------------------

#------------------------------------------------------------------------
# USAGE: 
# opticall_to_tfam.sh <my.calls> 
# e.g. opticall_to_tfam.sh myOpticall.calls 
# Output: mytped.tfam
#------------------------------------------------------------------------


#------------------------------------------------------------------------
# ARGS: 
# basename: filename root for a genome studio report file
#------------------------------------------------------------------------
basename=${1} 

#calls file
op_calls=${basename}_opticall-cat.calls

#output file
tfam_file="${basename}_opticall-cat.tfam" #output tfam file 
> ${tfam_file} #create empty file, and clobber 







#perl -lane 
#'
#@samples = @F[4..$#F];
#if($.==1){map ($_ =~ s/$/\n/, @samples);}
#map(printf "$_\s$_\s0\s0\s-9\s-9\n", @samples)
#'
#${op_calls}  > ${tfam_file}


perl -lane 'if($.==1) {@samples = @F[4..$#F]; map(printf("$_ $_ 0 0 -9 -9\n"), @samples);}' ${op_calls}  > ${tfam_file}


