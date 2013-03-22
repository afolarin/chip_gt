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
plink --noweb --bfile ${zcall_bed} --bmerge ${opticall_bed}.bed ${opticall_bed}.bim ${opticall_bed}.fam --merge-mode 6

#plink merge.mmode=7 -- Report mismatching non-missing calls (diff mode -- do not merge)
plink --noweb --bfile ${zcall_bed} --bmerge ${opticall_bed}.bed ${opticall_bed}.bim ${opticall_bed}.fam --merge-mode 7

