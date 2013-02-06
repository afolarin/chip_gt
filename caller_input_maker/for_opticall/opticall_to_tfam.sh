#!/bin/bash

#########################################################################
# -- Author: Amos Folarin                                               #
# -- Organisation: KCL/SLaM                                             #
# -- Email: amosfolarin@gmail.com                                       #
#########################################################################



#------------------------------------------------------------------------
# Build the TFAM file  *** ACTUALLY only want to build this for concatenated tped files or use the tfam from zcall??
# FORMAT: Family ID, Individual ID, Paternal ID, Maternal ID, Sex (1=male; 2=female; other=unknown), Phenotype
# e.g.  8129773134_R05C01 8129773134_R05C01 0 0 -9 -9
# need someway to pass in the sex and phenotype currently set to -9
# 
#------------------------------------------------------------------------





#------------------------------------------------------------------------
# ARGS: 
# op_calls: concatenated chunked call file
#------------------------------------------------------------------------
op_calls=$1  ##opticall calls concatenated file chunked by chromosome
op_tfam=${op_calls}.tfam #output tfam file




perl -lane 
'
@samples = @F[4..$#F];
if($.==1){map ($_ =~ s/$/\n/, @samples);}
map(printf "$_\s$_\s0\s0\s-9\s-9\n", @samples)
'
${op_calls}  > ${op_tfam}



