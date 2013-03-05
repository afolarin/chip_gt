#!/bin/sh
#$-S /bin/bash
#$-cwd
#$ -V

#########################################################################
# -- Author: Amos Folarin                                               #
# -- Organisation: KCL/SLaM                                             #
# -- Email: amosfolarin@gmail.com                                       #
#########################################################################


##################################################################################################
# Description: Perform Zcall. Run SGE batch job for zcall_doCall.sh, output .tped and .tfam files with zcalls.
# if arg4 the threshold file is provided then the calibration (or single threshold calc) step will not be carried out.
# USAGE: qsub -q <queue.q>  sge_zcall.sh <basename> <Z> <I> <threshold_file>
# ARGS: 
# arg1: parameter file name
# arg2: Z value
# arg3: I value
# arg4: threshold file generated during calibration
# OUTPUT: tped and tfam files with zcalls on the No Call SNPs
##################################################################################################



#args
basename=${1}
Z=${2}
I=${3}
tfile=${4}


#run job with optimal threshold file
/bin/bash zcall_doCall.sh ${basename} ${Z} ${I}  ${tfile}

