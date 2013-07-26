#!/bin/sh
#$-S /bin/bash
#$-cwd
#$-V

#########################################################################
# -- Author: Amos Folarin                                               #
# -- Organisation: KCL/SLaM                                             #
# -- Email: amosfolarin@gmail.com                                       #
#########################################################################

# DESC: Compare the bed files created by zcall and opticall using plink
# 	merge.modes 6 and 7.

# USAGE: sge_zcall-v-opticall.sh <zcall_bed_basename> <opticall_bed_basename>


# ARGS:
zcall_bed=${1}
opticall_bed=${2}


#------------------------------------------------------------------------
#
#------------------------------------------------------------------------

#plink merge.mode=6 -- Report all mismatching calls (diff mode -- do not merge)
plink --noweb --bfile ${zcall_bed} --bmerge ${opticall_bed}.bed ${opticall_bed}.bim ${opticall_bed}.fam --merge-mode 6 --out zcall_v_opticall;  ## makes zcall_v_opticall.diff

## counts off differences by SNP and samples

cat ./zcall_v_opticall.diff | sed '1,1d' | awk '{print $1}' | sort | uniq -c | sort -g -n -r -k 1 > ./zcall_v_opticall_snp_diff_counts.txt;

awk '{print $3}'  ./zcall_v_opticall.diff | grep -v "IID" | sort | uniq -c | sort -g -n -r -k 1 > ./zcall_v_opticall_sample_diff_counts.txt;


# edits by SJNewhouse, stephen.newhouse@kcl.ac.uk, 23.07.2013 : added --out zcall_v_opticall and counts of snp/sample differecnces


#plink merge.mmode=7 -- Report mismatching non-missing calls (diff mode -- do not merge)
#plink --noweb --bfile ${zcall_bed} --bmerge ${opticall_bed}.bed ${opticall_bed}.bim ${opticall_bed}.fam --merge-mode 7

