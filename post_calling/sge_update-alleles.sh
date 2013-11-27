#!/bin/sh
#$-S /bin/bash
#$-cwd
#$-V


#########################################################################
# -- Author: Amos Folarin                                               #
# -- Organisation: KCL/SLaM                                             #
# -- Email: amosfolarin@gmail.com                                       #
#########################################################################


#------------------------------------------------------------------------
# convert the AB allele calls to the TOP allele calls (use the mapping file
# in /home/afolarinbrc/workspace/git_projects/pipelines/exome_chip)
# HumanExome.A.update_alleles.txt
# USAGE:
# qsub -q <queue.q> sge_update-alleles.sh <myTPED_AB_root> <update_alleles_file>
#
# OUTPUT: 
# myTPED_AB_UA.bed bed file, which has had the alleles updated
#------------------------------------------------------------------------


# ARGS:
tped=${1}
update_alleles_file=${2}


#------------------------------------------------------------------------
# call plink to perform update alleles 
#------------------------------------------------------------------------
plink --noweb --tfile ${tped} --update-alleles ${update_alleles_file} --make-bed --out ${tped}_UA
#plink --noweb --tped ${tped} --update-alleles ${update_alleles_file} --make-bed --out ${tped}_UA


#------------------------------------------------------------------------
#
#------------------------------------------------------------------------


