#!/bin/sh
#$-S /bin/bash
#$-cwd
#$-V


#########################################################################
# -- Author: Amos Folarin                                               #
# -- Organisation: KCL/SLaM                                             #
# -- Email: amosfolarin@gmail.com                                       #
#########################################################################

#DESC:
# Because opticall input takes columns "<SAMPLE_NAME>.X" "<SAMPLE_NAME>.Y", in the output .calls 
# file thiscompressing this down to the "<SAMPLE_NAME>." rather than "<SAMPLE_NAME>" as in Zcall 
# the extra "." must be removed to make the sample names comparable in plink.

#USAGE:
# qsub sge_fix_opticall_fam-file.sh <basename>.fam

#ARGs: an opticall *.fam file produced with the *.bed file in the final step in the opticall pipeline
plink_fam=${1}

#------------------------------------------------------------------------
# inplace removal of the "." at the end of the sample names from the opticall .fam file
#------------------------------------------------------------------------
perl -i -lane '@F[0]=$F[0]=~/(.+)\.$/; @F[1]=$F[1]=~/(.+)\.$/; print( join(" ", "@F"))' plink_fam
