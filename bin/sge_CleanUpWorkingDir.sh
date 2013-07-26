#!/bin/sh
#$-S /bin/bash
#$-cwd
#$-V

#########################################################################
# -- Author: Stephen Newhouse                                           #
# -- Organisation: KCL                                                  #
# -- Email: stephen.newkouse@kcl.ac.uk                                  #
#########################################################################

## Usage : sge_CleanUpWorkingDir.sh <working_dir>

##
working_dir=${1}

echo "making new dir structre in " ${working_dir}

mkdir ${working_dir}/FINAL_ZCALL
mkdir ${working_dir}/FINAL_OPTICALL
mkdir ${working_dir}/zcall_opticall_concordance
mkdir ${working_dir}/zcall_proccessing
mkdir ${working_dir}/opticall_processing
mkdir ${working_dir}/sge_out
mkdir ${working_dir}/plink_qc_tmp

##
echo "moving sge out/errors to " ${working_dir}/sge_out/

mv -v ${working_dir}/*.e* ${working_dir}/sge_out/
mv -v ${working_dir}/*.o* ${working_dir}/sge_out/
mv -v ${working_dir}/*.pe* ${working_dir}/sge_out/
mv -v ${working_dir}/*.po* ${working_dir}/sge_out/

##
echo "moving zCall sd/beta/threshold files to  "${working_dir}/zcall_proccessing/

mv -v ${working_dir}/*.betas.txt ${working_dir}/zcall_proccessing/
mv -v ${working_dir}/*.mean.sd.txt ${working_dir}/zcall_proccessing/
mv -v ${working_dir}/*.output.thresholds.txt ${working_dir}/zcall_proccessing/
mv -v ${working_dir}/*.output.thresholds.stats.txt ${working_dir}/zcall_proccessing/
mv -v ${working_dir}/optimal.thresh ${working_dir}/zcall_proccessing/
mv -v ${working_dir}/*_filt* ${working_dir}/zcall_proccessing

##
echo "moving opticall in/out files to  "${working_dir}/opticall_proccessing/

mv -v ${working_dir}/*_opticall-* ${working_dir}/opticall_processing/

##
echo "moving Final Zcalls and Opticall genotypes to   " ${working_dir}/FINAL_ZCALL/ " AND " ${working_dir}/FINAL_OPTICALL/

mv -v ${working_dir}/*_Zcalls* ${working_dir}/FINAL_ZCALL/
mv -v ${working_dir}/*_Opticall* ${working_dir}/FINAL_OPTICALL/

##
echo "moving Final Zcalls V Opticall concordance results to " ${working_dir}/zcall_opticall_concordance/

mv -v ${working_dir}/zcall_v_opticall.*  ${working_dir}/zcall_opticall_concordance/

## 
echo "moving pre zcall and opticall plink qc files to  " ${working_dir}/plink_qc_tmp/

mv -v ${working_dir}/*.plinkQC_01* ${working_dir}/plink_qc_tmp/

mv -v ${working_dir}/*.plinkQC_02* ${working_dir}/plink_qc_tmp/

mv -v ${working_dir}/*.plinkQC_03* ${working_dir}/plink_qc_tmp/



mv -v ${working_dir}/*LDprun* ${working_dir}/plink_qc_tmp/
mv -v ${working_dir}/*.prune* ${working_dir}/plink_qc_tmp/
mv -v ${working_dir}/*_exclude ${working_dir}/plink_qc_tmp/
mv -v ${working_dir}/*_common_s* ${working_dir}/plink_qc_tmp/
mv -v${working_dir}/ *_callrat* ${working_dir}/plink_qc_tmp/
mv -v ${working_dir}/*_rare* ${working_dir}/plink_qc_tmp/



