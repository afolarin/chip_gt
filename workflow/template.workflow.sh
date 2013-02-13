#!/bin/bash

#########################################################################
# -- Author: Amos Folarin                                               #
# -- Organisation: KCL/SLaM                                             #
# -- Email: amosfolarin@gmail.com                                       #
#########################################################################

#------------------------------------------------------------------------
# Some environmental variables required for child processes (all )
#------------------------------------------------------------------------
# scripts bins pathed -- use git repo versions
exome_chip_bin=/home/afolarinbrc/workspace/git_projects/pipelines/exome_chip/bin/
zcall_bin=/share/apps/zcall_current/Version3_GenomeStudio/bin/
opticall_bin=/share/apps/opticall_current/bin
working_dir=cwd  #//TODO may want possibility of outputting to a different dir...
export PATH=$PATH:${exome_chip_bin}:${zcall_bin}:${opticall_bin}:${working_dir}


# report file basename e.g. moorfields_191112_zCall_01_filt_faster-version.report
# NOTE: if later this doesn't work with pegasus, just wrap them in a file pass and source
export data_path="/home/afolarinbrc/pipelines/DATA/exome_chip/GENDEP_test/"
export basename="gendep_11-002-2013_01"  # leave off suffix ".report" for basename



#------------------------------------------------------------------------
echo "Make a local copy of the report file"
# input: data location for gs.report
# output: working dir copy of gs.report
#------------------------------------------------------------------------
cp ${gs.report_path}/${basename}.report ${working_dir}/${basename}.report


#------------------------------------------------------------------------
echo "Convert GS to plink for QC input, output tped/tfam to working_dir"
# input: local gs.report
# output: local .tped & tfam files and ped & map files
# //TODO wrap this in a sge job.. 
#------------------------------------------------------------------------
convertReportToTPED.py -O ${working_dir}/${basename} -R ${working_dir}/${basename}
plink --noweb --tfile ${working_dir}/${basename} --make-ped --out ${working_dir}/${basename};

#------------------------------------------------------------------------
echo "Post-GenomeStudio Sample QC, output list of samples to drop "
# input: .ped file derived from the report
# output: output list of samples to drop: final_sample_exclude
# *****//TODO still some outstanding QC steps to implement*****
#------------------------------------------------------------------------
qsub -q short.q exome.qc.pipeline.v03.sh ${working_dir}/${basename} ${working_dir}/${basename}



#------------------------------------------------------------------------
echo "Drop bad samples from gs.report (local)"
# input: report file and samples to exclude
# output: report file ${basename}_filt.report cleaned of bad samples
# //TODO refactor removal of PARAMs_FILE
#------------------------------------------------------------------------
qsub -q short.q sge_dropBadSamples.sh ${working_dir}/${basename} ${working_dir}/final_sample_exclude



#------------------------------------------------------------------------
# OPTICALL BRANCH: 
echo "1) Opticall chunking by chr"
echo "2) Create opticall input files, 1 per chr"
echo "3) Run opticall as an array job on each chr"
echo "4) Create a tped from each chr chunk (later to be concatenated)"
# input: cleaned gs.report file
# output: 
#------------------------------------------------------------------------
qstat -q short.q sge_run_opticall.sh  -meanintfilter






#------------------------------------------------------------------------
# OPTICALL BRANCH: 
# create a tped from each chr chunk (later to be concatenated)
# input:
# output: 
#------------------------------------------------------------------------

#TODO





#------------------------------------------------------------------------
# ZCALL BRANCH: 
#
# input:
# output: 
#------------------------------------------------------------------------



#------------------------------------------------------------------------

# input:
# output: 
#------------------------------------------------------------------------




#------------------------------------------------------------------------
#ZCALL BRANCH: 
#
# input:
# output: 
#------------------------------------------------------------------------




#------------------------------------------------------------------------
# ZCALL BRANCH: 
#
# input:
# output: 
#------------------------------------------------------------------------




#------------------------------------------------------------------------
# ZCALL BRANCH: 
#
# input:
# output: 
#------------------------------------------------------------------------





#------------------------------------------------------------------------
# ZCALL BRANCH: 
#
# input:
# output: 
#------------------------------------------------------------------------



#------------------------------------------------------------------------
# ZCALL BRANCH: 
#
# input:
# output: 
#------------------------------------------------------------------------




