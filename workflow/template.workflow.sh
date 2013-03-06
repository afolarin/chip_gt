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
working_dir=`pwd`  #//TODO may want possibility of outputting to a different dir...
export PATH=$PATH:${exome_chip_bin}:${zcall_bin}:${opticall_bin}:${working_dir}


# report file basename e.g. moorfields_191112_zCall_01_filt_faster-version.report
# NOTE: if later this doesn't work with pegasus, just wrap them in a file pass and source
export data_path="/home/afolarinbrc/pipelines/DATA/exome_chip/GENDEP_test"
export basename="gendep_11-002-2013_01"  # leave off suffix ".report" for basename



#------------------------------------------------------------------------
# INITIAL QC
echo "Make a local copy of the report file"
# input: data location for gs.report
# output: working dir copy of gs.report
#------------------------------------------------------------------------
cp ${data_path}/${basename}.report ${working_dir}/${basename}.report


#------------------------------------------------------------------------
# INITIAL QC
echo "Convert GS to plink for QC input, output tped/tfam to working_dir"
# input: local gs.report
# output: local .tped & tfam files and ped & map files
# //TODO wrap this in a sge job.. 
#------------------------------------------------------------------------
convertReportToTPED.py -O ${working_dir}/${basename} -R ${working_dir}/${basename}.report
plink --noweb --tfile ${working_dir}/${basename} --make-bed --out ${working_dir}/${basename};
plink --noweb --bfile ${working_dir}/${basename} --recode --out ${working_dir}/${basename};

#NOTE: becasue you have made the bed file here, this step is duplicated in exome.qc.pipeline.v03.sh remove there /TODO


#------------------------------------------------------------------------
# INITIAL QC
echo "Post-GenomeStudio Sample QC, output list of samples to drop "
# input: .ped file derived from the report
# output: output list of samples to drop: final_sample_exclude
# *****//TODO still some outstanding QC steps to implement*****
#------------------------------------------------------------------------
#qsub -q short.q exome.qc.pipeline.v03.sh ${working_dir}/${basename} ${working_dir}/${basename} ## doesn't work, can't PATH exome.qc.pipeline.v03.sh
qsub -q short.q -N initial-QC ${exome_chip_bin}/exome.qc.pipeline.v03.sh ${working_dir}/${basename} ${working_dir}/${basename}


#------------------------------------------------------------------------
# INITIAL QC
echo "Drop bad samples from gs.report (local)"
# input: report file and samples to exclude
# output: report file ${basename}_filt.report cleaned of bad samples
#------------------------------------------------------------------------
qsub -q short.q -N drop-bad-samples  -hold_jid initial-QC ${exome_chip_bin}/sge_dropBadSamples.sh ${working_dir}/${basename} ${working_dir}/final_sample_exclude

# //TODO again there is a duplication of the report file, done to protect against dropping from an original file, so either keep duplication here and remove from step 1, or remove here...
## my feeling is it is better to leave the duplication here, so it behaves in a safe way if this is run independantly. This is the only step that has the potential to modify the .report file






# TODO -- move each branch line into a sparate script file so can run concurrently where they branch

#------------------------------------------------------------------------
# OPTICALL BRANCH: 
echo "1) Opticall chunking by chr"
echo "2) Create opticall input files, 1 per chr"
echo "3) Run opticall as an array job on each chr"
# input: cleaned gs.report file
# output: .calls and .prob files of opticall
#------------------------------------------------------------------------
qsub -q short.q -N run-optcall -hold_jid drop-bad-samples ${exome_chip_bin}/sge_run_opticall.sh ${working_dir}/${basename}_filt.report -meanintfilter


#------------------------------------------------------------------------
# OPTICALL BRANCH: 
echo "Concatenate all .calls file into a single .calls file"
# input: cleaned gs.report file basename
# output: a single file of aggregated .calls chunks 
#------------------------------------------------------------------------
qsub -q short.q -N concat-opticall -hold_jid run-opticall ${exome_chip_bin}/sge_opticall_concat.sh ${working_dir}/${basename}

#------------------------------------------------------------------------
# OPTICALL BRANCH: 
echo "Convert each chunked .calls file into chunked .tped files"
echo "Concatenate all chunked .tped files into a single .tped file"
echo "Create corresponding .tfam file for the aggregate .tped"
# input: cleaned gs.report file basename
# output: tped created from the chromosome chunked .calls files, these are combined back into a single tped file
#------------------------------------------------------------------------
qsub -q short.q -N optcall2plink -hold_jid concat-opticall ${exome_chip_bin}/sge_op2plink_concat.sh ${working_dir}/${basename}




#------------------------------------------------------------------------
# OPTICALL BRANCH: 
# POST CALLING STEPS: 
echo "Update Alleles for Opticall tped"
echo ""
# plink update-alleles 
# input: basename of concatenated opticall tped
# output: tped file with updated alleles
#------------------------------------------------------------------------
qsub -q short.q -N update-alleles -hold_jid optcall2plink ${exome_chip_bin}/sge_update-alleles.sh ${working_dir}/${basename}_opticall-cat /home/afolarinbrc/workspace/git_projects/pipelines/exome_chip/PLINK_update-alleles_map/HumanExome.A.update_alleles.txt






# TODO -- move each branch line into a sparate script file so can run concurrently where they branch

#------------------------------------------------------------------------
# ZCALL BRANCH: 
echo "Calibrate Z, find Z which has the best concordance with Gencall"
echo "The R script global.concordance.R will calculate the optimal z"
# input:
# output: 
#------------------------------------------------------------------------
qsub -q short.q sge_calcThresholds ${working_dir}/${basename} 0.2
optimal_threshold_file=`Rscript global.concordance.R ${working_dir}`


#------------------------------------------------------------------------
# ZCALL BRANCH: 
echo "Run Z call, with the calibrated threshold file"
echo ""

# input:
# output: 
#------------------------------------------------------------------------

#run with precalculated threshold file
qsub -q short.q  sge_zcall.sh ${basename} ${optimal_threshold_file=}

# or run and calculate threshold from provided Z and I
# qsub -q <queue.q>  sge_zcall.sh <basename> <Z> <I>


#------------------------------------------------------------------------
# ZCALL BRANCH: 
echo "Post zcall filtering, just a sanity check??? see Jackie Goldstein and Sanger Exome chip group protocols"
echo ""

# input:
# output: 
#------------------------------------------------------------------------
 sge_post-z-qc.sh <tpedBasename>





#------------------------------------------------------------------------
echo ""
echo ""
# input:
# output: 
#------------------------------------------------------------------------





#------------------------------------------------------------------------
# input:
# output: 
#------------------------------------------------------------------------



#------------------------------------------------------------------------
# Question to user: do you want to run cleanup script?
# WARNING: this will remove intermdiary files which you may want to look at,
# and you can always run this at a later date by running xxxxxx-cleanup.sh
# input:
# output: 
#------------------------------------------------------------------------




