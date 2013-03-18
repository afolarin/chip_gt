#!/bin/bash

#########################################################################
# -- Author: Amos Folarin                                               #
# -- Organisation: KCL/SLaM                                             #
# -- Email: amosfolarin@gmail.com                                       #
#########################################################################

#DESC:
# Simple script to call the steps required to run Z-Call Version 3 genotyping
# If you have already run z calibration or have a threshold file at the appropriate Z and I,
# then you can run zcall with a given threshold file. Either specify the thresholds file explicitly with
# the -T option or specify a file containing the threshold filename e.g. output of global calibration script
# with the -O option. 

#ARGS:
# -W: working dir (provide separate to the basename for this script)
# -B: basename the basename of the report file, typically specified with the path for the working dir
#     ${zcall_path} and ${basename} variables now defined in ZCALL_PARAMs.sh file, which is included in the calling sge script
# -T: (alternative): threshold file which corresponded to the optimum z concordance, these files were calculated in the calibration phase
# -C: or "optimal.thresh" a one line file with the name of the optimal threshold file  (generated during calibration + global concordance step)

#USAGE:
# USAGE1: zcall_doCall.sh basename thresholdfile
wkdir=
basename=
thresholdfile=

# parse in the CMD Line args
while getopts ":W:B:T:C:" opt
do
	case $opt in
		W)
		wkdir=${OPTARG}
		;;
		B)
		basename=${OPTARG}
		;;
		T)
		thresholdfile=${OPTARG}
		;;
		C)
		thresholdfile=${OPTARG} # if using optimal.thresh then extract the name of the threshold file from "optimal.thresh" file 
		thresholdfile=`grep ${basename} ${thresholdfile}`
		;;
		\?)
		echo "Invalid option: -$OPTARG" >&2
		;;
	esac
done
basename=${wkdir}/${basename}



echo "+**************************************************+"
echo "PARAMS"
echo "basename = ${basename}"
echo "thresholdfile =  ${thresholdfile}"
echo "+**************************************************+"
echo "Started: "`date`


if [ -e ${thresholdfile} ]
then

	#4) Re-call with zcall all No Call (NC) SNPS from Gencall 
	# -R GS report file to call
	# -T threshold file
	# -O output basename for tped/tfam
	echo "4) Re-calling the No Call (NC) SNPS with zcall"
	echo call: zCall.py -R ${basename}".report" -T ${thresholdfile} -O ${basename}"_Zcalls"
	zCall.py -R ${basename}".report" -T ${thresholdfile} -O ${basename}"_Zcalls"
	echo "Finished: "`date`

else
	echo "problem with threshold file: ${thresholdfile}" 1>&2 
fi

