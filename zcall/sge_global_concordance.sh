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
#Call global concordance to calculate the best value of Z from the zcall run
#should only be run after all the threshold calculating array jobs are finished
#which is why it put in it's own SGE job. 

#USAGE:
#qsub -q <queue.q> sge_global_concordance.sh <working dir path>

#ARGS:
working_dir=${1} # ${working_dir}


#------------------------------------------------------------------------
# call the Rscript to calc global concordance
#------------------------------------------------------------------------
Rscript `which global_concordance.R` ${working_dir}

