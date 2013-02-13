#!/bin/sh
#$-S /bin/sh
#$-cwd
#$-t 3-15
#$ -V

#########################################################################
# -- Author: Amos Folarin                                               #
# -- Organisation: KCL/SLaM                                             #
# -- Email: amosfolarin@gmail.com                                       #
#########################################################################


#Description: Run SGE batch job to get calibration thresholds from z=3 to z=15 for zcall-v3.3_steps
#USAGE: qsub -q <queue.q> sge_calcThresholds.sh <data_path> <basename> <min-intensity>

# args
data_path=${1}
basename=${2}
I=${3}

#call zcall_doCall.sh for the thresholds
/bin/bash zcall_doCall.sh ${data_path} ${basename} $SGE_TASK_ID ${I}

