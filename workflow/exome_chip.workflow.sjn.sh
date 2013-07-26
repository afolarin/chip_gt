#!/bin/bash

#########################################################################
# -- Author: Amos Folarin                                               #
# -- Organisation: KCL/SLaM/BRC-MH                                      #
# -- Email: amosfolarin@gmail.com                                       #
# -- Edits: Stephen Newhouse, stephen.newhouse@kcl.ac.uk, 23.07.2013    #
#########################################################################

# DESC:

# Genotype calling for Exome Chip.
# This is the template script for running the exome chip pipeline this will run 
# from the input of a Genome Studio report file (zcall format, see docs)

# 1) Run QC on the report file
# 2) Run Opticall -- output:  <name>_filt_Opticall.bed
# 2) Run Zcall -- output:  <name>_filt_Zcall.bed
# 3) Compare results of the two rare genotype callers and output list of SNPs and SAMPLES that differ in GT call between Zcall and Opticall  
# 4) Run veru basic QC on called genotypes : freq, HWE, missing and genotype based sex check
# 5) Cleans up working directory

# USAGE:
##### require enviromnental variables populated correctly



# 1) exome_chip_bin = path to the pipeline bin with the scripts bin (....pipelines/exome_chip/bin/)
# available on 

# 2) zcall_bin = path to the zcall bin

# 3) working_dir= path to working dir, use pwd when run from the working dir (typical usage)

##### for each dataset run through the pipeline define these paths
# 4) update_alleles file, select the correct on for your chiptype. see the pipelines/exome_chip/PLINK_update-alleles_map. if not there then see the README in  that dir

# 5) data_path = path to folder containing the genome studio report file 

# 6) basename = the filename root of the Genome Studio report file (in Zcall format)

# 7) queue_name = Sun Grid Engine queue name 

###############################
##### execute the pipeline ####
###############################

# sh exome_chip.workflow.sjn  <working_dir> <data_path> <updata_alleles_file> <basename> 



#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------# 

echo " START PIPELINE " `date`

#------------------------------------------------------------------------
# Some environmental variables required for child processes (all) and 
# therefore are passed on by the environment variable -V in sge scripts
#------------------------------------------------------------------------

# scripts bins pathed -- use git repo versions

exome_chip_bin="/home/afolarinbrc/workspace/git_projects/pipelines/exome_chip/bin/"

zcall_bin="/share/apps/zcall_current/Version3_GenomeStudio/bin/"

opticall_bin="/share/apps/opticall_current/bin"

#----------------------------------##
## set/get OPTS from commanmd line ##
#----------------------------------##

working_dir=${1}  # PATH TO WHERE YOU WANT ALL OUTPUT
export PATH=$PATH:${exome_chip_bin}:${zcall_bin}:${opticall_bin}:${working_dir}
export data_path=${2} # PATH TO GS REPORT FILE
update_alleles_file=${3} # PATH/NAME.txt of update alleles file. email us for details. MUST MATCH YOUR GENOTYPING CHIP, TYPE/VERSION !!!!!!!!!!!!!!!!!!
export basename=${4}  # leave off suffix ".report" for basename. Report from GS

###############
## set SGE Q ##
###############

queue_name="short.q,long.q" 

######################### START INITIAL QC ##############################

#------------------------------------------------------------------------
# INITIAL QC
echo "Make a local copy of the report file"
# input: data location for gs.report
# output: working dir copy of gs.report
#------------------------------------------------------------------------
cp -v ${data_path}/${basename}.report ${working_dir}/${basename}.report


#------------------------------------------------------------------------
# INITIAL QC
echo "Convert GenomeStudio report file to Plink (ped) for QC input, output tped/tfam to working_dir"
# input: local gs.report
# output: local .tped & tfam files and ped & map files
# //TODO wrap this in a sge job.. 
#------------------------------------------------------------------------
qsub -q ${queue_name} -N report2ped  ${exome_chip_bin}/sge_GSreport2ped.sh ${working_dir}/${basename}

#convertReportToTPED.py -O ${working_dir}/${basename} -R ${working_dir}/${basename}.report
#plink --noweb --tfile ${working_dir}/${basename} --make-bed --out ${working_dir}/${basename}; #converting .tped --> .ped requires intermediate .bed file 
#plink --noweb --bfile ${working_dir}/${basename} --recode --out ${working_dir}/${basename};

#NOTE: becasue you have made the bed file here, this step is duplicated in exome.qc.pipeline.v03.sh remove there /TODO


#------------------------------------------------------------------------
# INITIAL QC
echo "Post-GenomeStudio Sample QC, output list of samples to drop "
# input: .ped file derived from the report
# output: output list of samples to drop: final_sample_exclude
# *****//TODO still some outstanding QC steps to implement*****
#------------------------------------------------------------------------
qsub -q ${queue_name} -N initial-QC -hold_jid report2ped ${exome_chip_bin}/exome.qc.pipeline.v04.sh ${working_dir}/${basename} ${working_dir}/${basename}


#------------------------------------------------------------------------
# INITIAL QC
echo "Drop bad samples from gs.report (local)"
echo "ALL subsequent work carried out on the ${basename}_filt.report, which is the QC'd file"
# input: report file and samples to exclude
# output: report file ${basename}_filt.report cleaned of bad samples
#------------------------------------------------------------------------
qsub -q ${queue_name} -N drop-bad-samples  -hold_jid initial-QC ${exome_chip_bin}/sge_dropBadSamples.sh ${working_dir}/${basename} ${working_dir}/final_sample_exclude

######################### END INITIAL QC ##############################




######################### START OPTICALL BRANCH ##############################


# TODO -- move each branch line into a sparate script file so can run concurrently where they branch

#------------------------------------------------------------------------
# OPTICALL BRANCH: 
echo "1) Opticall chunking by chr"
echo "2) Create opticall input files, 1 per chr"
echo "3) Run opticall as an array job on each chr"
# input: cleaned gs.report file
# output: .calls and .prob files of opticall
#------------------------------------------------------------------------
#1) chunk the Genome Studio report file by chromosom
qsub -q ${queue_name} -N chunking -hold_jid drop-bad-samples ${exome_chip_bin}/sge_opticall_chunker.sh ${working_dir}/${basename}_filt.report ${working_dir}/${basename}_filt.report
qsub -q ${queue_name} -N run-opticall -hold_jid chunking ${exome_chip_bin}/sge_run_opticall.sh ${working_dir}/${basename}_filt.report -meanintfilter


#------------------------------------------------------------------------
# OPTICALL BRANCH: 
echo "Concatenate all .calls file into a single .calls file"
# input: cleaned gs.report file basename
# output: a single file of aggregated .calls chunks 
#------------------------------------------------------------------------
qsub -q ${queue_name} -N concat-opticall -hold_jid run-opticall ${exome_chip_bin}/sge_opticall_concat.sh ${working_dir}/${basename}  


#------------------------------------------------------------------------
# OPTICALL BRANCH: 
echo "Convert each chunked .calls file into chunked .tped files"
echo "Concatenate all chunked .tped files into a single .tped file"
echo "Create corresponding .tfam file for the aggregate .tped"
# input: cleaned gs.report file basename
# output: tped created from the chromosome chunked .calls files, these are combined back into a single tped file
#------------------------------------------------------------------------
qsub -q ${queue_name} -N opticall2plink -hold_jid concat-opticall ${exome_chip_bin}/sge_op2plink_concat.sh ${working_dir}/${basename}




#------------------------------------------------------------------------
# OPTICALL BRANCH: 
# POST CALLING STEPS: 
echo "Update Alleles for Opticall tped"
echo ""
# plink update-alleles 
# input: basename of concatenated opticall tped
# output: .bed file with updated alleles
#------------------------------------------------------------------------
qsub -q ${queue_name} -N update-alleles_oc -hold_jid opticall2plink ${exome_chip_bin}/sge_update-alleles.sh ${working_dir}/${basename}_filt_Opticall ${update_alleles_file} 

#small fix for the .fam file produced with opticall, remove the "." left on samplenames created
qsub -q ${queue_name} -N fix-oc-fam-file -hold_jid update-alleles_oc  ${exome_chip_bin}/sge_fix_opticall_fam-file.sh ${working_dir}/${basename}_filt_Opticall_UA.fam


# convert bed to ped
# e.g. plink --noweb --bfile gendep_11-002-2013_01_opticall-cat_UA --recode --out gendep_11-002-2013_01_opticall-cat_UA




############## END OF OPTICALL######################



############## START OF ZCALL ######################
#------------------------------------------------------------------------
# ZCALL BRANCH: 
echo "Calibrate Z, find Z which has the best concordance with Gencall"
echo "The R script global.concordance.R will calculate the optimal z"
# input: working directory, minimum intensity (default value 0.2)
# output: zcall threshold files, stats files
#------------------------------------------------------------------------
qsub -q ${queue_name} -N calcThresh -hold_jid drop-bad-samples ${exome_chip_bin}/sge_calcThresholds.sh ${working_dir}/${basename}_filt 0.2
qsub -q ${queue_name} -N gConcordance -hold_jid calcThresh ${exome_chip_bin}/sge_global_concordance.sh ${working_dir}


#------------------------------------------------------------------------
# ZCALL BRANCH: 
echo "Run Z call, with the calibrated threshold file"
echo ""

# input: basename and optimal threshold file, this is listed in the "optimal.thresh" file after running global concordance
# output: zcalls in tped/tfam Plink format
#------------------------------------------------------------------------
#run with precalculated threshold file
qsub -q ${queue_name} -N zcalling -hold_jid gConcordance ${exome_chip_bin}/sge_zcall.sh ${working_dir} ${basename}_filt ${working_dir}/optimal.thresh

#------------------------------------------------------------------------
# ZCALL BRANCH: 
# POST CALLING STEPS: 
echo "Update Alleles for ZCall tped"
echo ""
# plink update-alleles 
# input: basename of zcall tped
# output: .bed file with updated alleles
#------------------------------------------------------------------------
qsub -q ${queue_name} -N update-alleles_zc -hold_jid zcalling ${exome_chip_bin}/sge_update-alleles.sh ${working_dir}/${basename}_filt_Zcalls ${update_alleles_file} 

################ END OF ZCALL###########################


################# POST CALLING BASIC QC AND COMPARISONS ################

#------------------------------------------------------------------------
# Compare the Zcall and Opticall calls
#------------------------------------------------------------------------
echo "Comapre the Zcall and Opticall calls"
echo ""
qsub -q ${queue_name} -N compareCalls -hold_jid update-alleles_zc,fix-oc-fam-file ${exome_chip_bin}/sge_zcall-v-opticall.sh ${working_dir}/${basename}_filt_Zcalls_UA ${working_dir}/${basename}_filt_Opticall_UA
 
#------------------------------------------------------------------------
# BASIC PLINK QC of the Zcall and Opticall calls 
# SJNewhouse, stephen.newhouse@kcl.ac.uk, 23.07.2013 
#------------------------------------------------------------------------
echo "running some very basic plink QC on the final calls produced by zCall and Opticall"
echo ""
qsub -q ${queue_name} -N basicQCfinalCalls -hold_jid compareCalls ${exome_chip_bin}/sge_basic_plinkqc_zcall_and_opticall.sh ${working_dir}/${basename}_filt_Zcalls_UA ${working_dir}/${basename}_filt_Opticall_UA

################# END POST CALLING BASIC QC AND COMPARISONS ################


################# START CLEAN UP  ################

#------------------------------------------------------------------------
# Clean up  SJN EDIT
# added by SJNewhouse, stephen.newhouse@kcl.ac.uk, 23.07.2013 
#------------------------------------------------------------------------
echo "Cleaning up working directory"
echo ""
qsub -q ${queue_name} -N CleanUpWorkingDir -hold_jid basicQC_final_calls ${exome_chip_bin}/sge_CleanUpWorkingDir.sh ${working_dir}


################# END CLEAN UP  ################

echo " END PIPELINE " `date`

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#------------------------------------------------------------------------
# Review pipeline execution and errors
#------------------------------------------------------------------------
#echo "Pipeline execution: Ctrl+c to exit 'watch qstat'"
#watch qstat
#echo "List sge error message files, review for errors where filesize > 0 bytes"
#ls -l *.e*


## SJN TOTDO: NEW README AT END OF RUN!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


#------------------------------------------------------------------------
# TODO: Question to user: do you want to run cleanup script?
#  WARNING: this will remove intermdiary files which you may want to look at,
#  and you can always run this at a later date by running xxxxxx-cleanup.sh
#------------------------------------------------------------------------

#------------------------------------------------------------------------
# Create a report file to which are the pertinent files in the
# working directory
#echo "Pertinent files are listed in the Pipeline_Report.txt"
#------------------------------------------------------------------------
#cat >>Pipeline_Report.txt <<EOF
#-------------------------------------------------------------------
#-------------------------SUMMARY REPORT----------------------------
#Here are a list of files which represent endpoints for the pipeline,
#these are primarily, inputs for analysis in Plink
#
#------Opticall Files------
#Concatenated Opticall Calls file: ${basename}_filt_opticall-cat.calls
#Output calls file: ${basename}_filt_Opticall.tped
#Updated Alleles calls file: ${basename}_filt_Opticall_UA.bed, ${basename}_filt_Opticall_UA.bim, ${basename}_filt_Opticall_UA.fam
#
#
#------Zcalll Files--------
#Output calls file: ${basename}_filt_Zcalls.tped
#Updated Alleles calls file: ${basename}_filt_Zcalls_UA.bed,  ${basename}_filt_Zcalls_UA.bim, ${basename}_filt_Zcalls_UA.fam
#
#
#------Zcall vs Opticall Comparison--------
#Plink merge-mode=6 comparison: plink.diff
#Optical v Zcall concordance: plink.log
#
#
#NOTE: to cleanup the directory run the /pipelines/exomechip/
#
#EOF



