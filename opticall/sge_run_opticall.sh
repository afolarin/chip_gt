#!/bin/sh
#$-S /bin/bash
#$-cwd
#$-t 1-26
#$-V

#########################################################################
# -- Author: Amos Folarin                                               #
# -- Organisation: KCL/SLaM                                             #
# -- Email: amosfolarin@gmail.com                                       #
#########################################################################

# This script runs a SGE array job. 1 per 26 chromosomes
# 1) chunks a GenomeStudio report file by chromosome
# 2) creates an opticall input file from a GenomeStudio report file chunked by chromosome
# 3) runs opticall http://www.sanger.ac.uk/resources/software/opticall/

# Opticall options can be passed in to this script as the 2nd ARG, 
# see opticall documentation for more detail.
# http://opticall.bitbucket.org/
# The chromosome exclusion options -X,-Y,-XY,-MT args are hardcoded here 
# and do not need to be passed in again. 
# If you have not dealt with outlying intensities you should use the
# "-meanintfilter" option. You can pass as the 2nd arg opticall standard
# options e.g. "-info FILE" to specify gender and groups e.g. ethnicities 

# USAGE: qstat -q <queue.q> sge_run_opticall.sh <GS_reportfile.report> ["opticall options"]
#e.g. qstat -q short.q sge_run_opticall.sh  myGS-report.report -meanintfilter


# ARGS: 
# #1) gs_report: a GenomeStudio report file <GS_reportfile> 
gs_report=${1} 
# #2) opticall_args: additional arguements to opticall "see opticall documentation" except the Chromosome options which are already included
opticall_args=${2}  


## PATHS:
## script paths
# spath="/home/afolarinbrc/workspace/git_projects/pipelines/exome_chip/caller_input_maker/for_opticall"
## opticall appliation 
# opticall_path="/share/apps/opticall_current/bin"


# chr array
declare -a chrs=("1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "X" "Y" "XY" "MT")

#1) chunk the Genome Studio report file by chromosome
opticall_chunker.sh ${gs_report} ${gs_report}  

# 2) create opticall inputs from chunked GS report files
opticall_input_from_GS-report.sh ${gs_report}"_Chr_${chrs[${SGE_TASK_ID}-1]}"

opti_in=${gs_report}"_Chr_${chrs[${SGE_TASK_ID}-1]}_opticall-in"
opti_out=${gs_report}"_Chr_${chrs[${SGE_TASK_ID}-1]}_opticall-out"

# 3) run opticall on the chromosome for the given sge_task_id
# Autosomal chromosomes
if [ ${SGE_TASK_ID} -le 22 ]
then
opticall ${opticall_args}  -in ${opti_in} -out ${opti_out}
fi

# Other chromosomes 
if [ ${SGE_TASK_ID} -eq 23 ]
then
opticall ${opticall_args} -X -in  ${opti_in} -out ${opti_out}
fi

if [ ${SGE_TASK_ID} -eq 24 ]
then
opticall  ${opticall_args} -Y  -in  ${opti_in} -out ${opti_out}
fi

if [ ${SGE_TASK_ID} -eq 25 ]
then
opticall ${opticall_args} -XY -in  ${opti_in} -out ${opti_out}
fi


if [ ${SGE_TASK_ID} -eq 26 ]
then
opticall ${opticall_args} -MT  -in  ${opti_in} -out ${opti_out}
fi

