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
# This carries a few post Opticall tasks out, primarily for getting Plink input 
# 1) Make tped files from opticall chunked .calls files and concatenate them into a single .tped
# 2) Make the corresponding .tfam file for the concatenated .tped, needed to perform update alleles in Plink.

#USAGE:
#bash sge_op2plink_concat.sh <basename>


#ARGS:
basename=${1}   #the GenomeStudio report's basename

#------------------------------------------------------------------------
# Concatenate:
# 1. all the chunked calls from opticall
#------------------------------------------------------------------------

ped_file="${basename}_opticall-cat.tped"
> ${ped_file}  #create empty file, and clobber


# Iterate through each chromosome chunk file,  
for i in `seq 1 26`;
do
	#autosomes
	if [ ${i} -le 22 ]
	then
		
		#create the chunk tped
       		bash opticall_to_tped.sh ${basename}_filt.report_Chr_${i}_opticall-out.calls
		#concatenate the chunk tped to the main tped
		cat  ${basename}_filt.report_Chr_${i}_opticall-out.calls.tped >> ${ped_file}

	fi
	
	# Other chromosomes 
	if [ ${i} -eq 23 ]
	then
		#create the chunk tped
                bash opticall_to_tped.sh ${basename}_filt.report_Chr_X_opticall-out.calls
                #concatenate the chunk tped to the main tped
                cat  ${basename}_filt.report_Chr_X_opticall-out.calls.tped >> ${ped_file}
	fi

	if [ ${i} -eq 24 ]
	then
		#create the chunk tped
                bash opticall_to_tped.sh ${basename}_filt.report_Chr_Y_opticall-out.calls
                #concatenate the chunk tped to the main tped
                cat  ${basename}_filt.report_Chr_Y_opticall-out.calls.tped >> ${ped_file}
	fi
	
	if [ ${i} -eq 25 ]
	then
		#create the chunk tped
                bash opticall_to_tped.sh ${basename}_filt.report_Chr_XY_opticall-out.calls
                #concatenate the chunk tped to the main tped
                cat  ${basename}_filt.report_Chr_XY_opticall-out.calls.tped >> ${ped_file}
	fi
	
	
	if [ ${i} -eq 26 ]
	then
		#create the chunk tped
                bash opticall_to_tped.sh ${basename}_filt.report_Chr_MT_opticall-out.calls
                #concatenate the chunk tped to the main tped
                cat  ${basename}_filt.report_Chr_MT_opticall-out.calls.tped >> ${ped_file}
	fi

done

# Now create the tfam file for ${ped_file}  
bash opticall_to_tfam.sh ${basename} # note as using the concatenated .calls file for source of sample ids this file needs to exist, the same info is in all the .calls headers though



