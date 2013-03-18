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
#qsub -q <queue.q>  sge_zcall.sh <basename> <threshold_file>

#ARGS: 
# arg1 : genome studio report basename
# arg2 : threshold file generated during calibration 
#        or the file "optimal.thresh" which is a single line file holding the optimal threshold filename


#args
wkdir=${1}
basename=${2}
tfile=${3}


#run job with optimal threshold file
/bin/bash call_zcalls.sh -W ${wkdir} -B ${basename} -C ${tfile}

