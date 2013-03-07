#!/bin/sh
#$-S /bin/bash
#$-cwd
#$ -V

#########################################################################
# -- Author: Amos Folarin                                               #
# -- Organisation: KCL/SLaM                                             #
# -- Email: amosfolarin@gmail.com                                       #
#########################################################################


#DESC: 
#Perform Zcall. Run SGE batch job for zcall_doCall.sh, output .tped and .tfam files with zcalls.
# the threshold file is should be the optimal file if calibration was run otherwise 
# select create a default threshold file at z=7 as per Zcalls documentation.

#USAGE: 
#qsub -q <queue.q>  sge_zcall.sh <basename> <Z> <I> <threshold_file>

#ARGS: 
# arg1: genome studio report basename
# arg2: threshold file generated during calibration

#OUTPUT: 
# tped and tfam files with zcalls on the No Call SNPs



#args
basename=${1}
tfile=${2}


#run job with optimal threshold file
/bin/bash call_zcalls.sh ${basename} ${tfile}

