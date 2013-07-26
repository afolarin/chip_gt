#!/bin/sh
#$-S /bin/bash
#$-cwd
#$-V

#########################################################################
# -- Author: Stephen Newhouse                                           #
# -- Organisation: KCL                                                  #
# -- Email: stephen.newkouse@kcl.ac.uk                                  #
#########################################################################

# DESC: Basic PLINK QC ON ZCALL AND OPTICALLED DATA 

# USAGE: sge_basic_plinkqc_zcall_and_opticall.sh  <zcall_bed_basename> <opticall_bed_basename>

# ARGS:
zcall_bed=${1}
opticall_bed=${2}


#------------------------------------------------------------------------
#
#------------------------------------------------------------------------

## Freq, HWE and missing rates
for i in freq hardy miss;do
plink --noweb --bfile ${zcall_bed}    --allow-no-sex --out ${zcall_bed}    --${i};
plink --noweb --bfile ${opticall_bed} --allow-no-sex --out ${opticall_bed} --${i};
done;

## counts
plink --noweb --bfile ${zcall_bed}    --allow-no-sex --out ${zcall_bed}    --freq --counts;
plink --noweb --bfile ${opticall_bed} --allow-no-sex --out ${opticall_bed} --freq --counts;

## check sex
plink --noweb --bfile ${zcall_bed}    --allow-no-sex --out ${zcall_bed}    --chr 23 --maf 0.05 --geno 0.02 --check-sex;
plink --noweb --bfile ${opticall_bed} --allow-no-sex --out ${opticall_bed} --chr 23 --maf 0.05 --geno 0.02 --check-sex;


