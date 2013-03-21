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
# DESC:
# convertes a GenomeStudio report file to a ped, through intermediate bed file

# USAGE:
# 

# ARGS
# basename: the file root of a genome studio file

#------------------------------------------------------------------------

#args
basename=${1}



convertReportToTPED.py -O ${basename} -R ${basename}.report
plink --noweb --tfile ${basename} --make-bed --out ${basename}; #converting .tped --> .ped requires intermediate .bed file 
plink --noweb --bfile ${basename} --recode --out ${basename};

#NOTE: becasue you have made the bed file here, this step is duplicated in exome.qc.pipeline.v03.sh remove there /TODO


