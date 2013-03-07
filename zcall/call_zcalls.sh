#!/bin/bash

#########################################################################
# -- Author: Amos Folarin                                               #
# -- Organisation: KCL/SLaM                                             #
# -- Email: amosfolarin@gmail.com                                       #
#########################################################################

#DESC:
# Simple script to call the steps required to run Z-Call Version 3 genotyping
# If you have already run z calibration or have a threshold file at the appropriate Z and I,
# then you can run zcall with a given threshold file. 

#ARGS:
# arg1: basename the basename of the report file, typically specified with the path for the working dir
#       ${zcall_path} and ${basename} variables now defined in ZCALL_PARAMs.sh file, which is included in the calling sge script
# arg2 (alternative): path to threshold file which corresponded to the optimum z concordance, these files were calculated in the calibration phase

#USAGE:
# USAGE1: zcall_doCall.sh basename thresholdfile


# pass in the CMD Line args
basename=${1}
thresholdfile=${2}


echo "+**************************************************+"
echo "PARAMS:"
echo "basename = ${basename}"
echo "thresholdfile =  ${thresholdfile}"
echo "+**************************************************+"
echo "Started: "`date`


if [ -e ${thresholdfile} ]
then

	# If a threshold file was provided as an arg then jump straight to z calling
	#4) Re-call with zcall all No Call (NC) SNPS from Gencall 
	echo "4) Re-calling the No Call (NC) SNPS with zcall"
	echo call: python ${zcall_path}/zCall.py -R ${data_path}/${basename}".report" -T ${thresholdfile} -O ${basename}".tped_tfam"
	zCall.py -R ${basename}".report" -T ${thresholdfile} -O ${basename}".tped_tfam"
	echo "Finished: "`date`

else
	echo "problem with threshold file: ${thresholdfile}" 1>&2 
fi

