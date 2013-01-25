#!/bin/sh

####################################################################################################
# Simple script to call the steps required to run Z-Call Version 3 to run as a Sun Grid Engine job:
# Requirements: the GenomeStudio report file, filenames will use the stem of this file as their base
# Run from within the directory with the GenomeStudio report file, relevant files will also be output to this current working dir.
# arg1: parameter file, e.g ZCALL_PARAMs.sh for example
#       ${zcall_path} and ${basename} variables now defined in ZCALL_PARAMs.sh file, which is included in the calling sge script
# arg2: z-score for threshold calculation (default 7)
# arg3: minimum mean signal intensity (default 0.2)
# arg4 (alternative): path to threshold file which corresponded to the optimum z concordance, these files were calculated in the calibration phase

###### USAGE OPTIONS:
# If you have already run z calibration, then you can run zcall with a given threshold file, which will be faster
# USAGE1: zcall_doCall.sh paramfile thresholdfile

# If you want to skip calibration or and generate a the threshold file from scratch then provide Z and I values
# USAGE2: zcall_doCall.sh paramfile 7 0.2

# calibrateZ script also calls this as part of scanning a range of z for optimal values
# Calibration is necessary and is recommended to be done per-scanner, using at least 1000samples
# good results however can be achieved by skipping calibration and using the default z=7
#####################################################################################################

# Set the CMD Line args here
params=${1}
Z=${2}
I=${3}
thresholdfile=${4}

echo $params $Z $I $thresholdfile


# source the params file here for ${zcall_path} and ${basename} etc..
source ${params}


echo "+**************************************************+"
echo " USING: report file::${basename}.report"
echo " USING: threshold file:: ${thresholdfile}"
echo " or if no threshold file provided then generate one"
echo " at the given Z=${Z} and I=${I}"
echo "+**************************************************+"
echo "Started: "`date`





if ! [ -e $thresholdfile ]
then
	#Scenario 1: calculate the threshold file at the given value of Z and I

	#now add calibration info to basename
	basename_c=${basename}"_z=${Z}""_i=${I}"

	if [ -e calibrateZ_out ] && [ -d calibrateZ_out ]
	then
		cd ./calibrateZ_out
	else
		mkdir calibrateZ_out
		cd ./calibrateZ_out
	fi


	#1) Calculating mean and standard deviation for each X,Y pair over SNP x Samples
	echo "1) Calculating mean and standard deviation for each X,Y pair over SNP x Samples"
	python ${zcall_path}"/findMeanSD.py"  -R ${data_path}/${basename}".report" > ${basename_c}".mean.sd.txt"


	#2) Regression coefficients for the mean and stdev
	echo "2) Calculating regression coefficients for the mean and stdev "
	Rscript  ${zcall_path}"/findBetas.r" ${basename_c}".mean.sd.txt" ${basename_c}".betas.txt" 1

	#3) Derive thresholds tx and ty which are z standard deviations from the meani
	echo "3) Deriving thresholds tx and ty; which taken as z standard deviations from the mean"
	python ${zcall_path}"/findThresholds.py" -B ${basename_c}".betas.txt" -R ${data_path}/${basename}".report" -Z ${Z} -I ${I} > ${basename_c}".output.thresholds.txt"

	#4) run calibratez to get the statistic relating to concordance between Gencall and ZCall at the given threshold calculated above
	echo "Calibrating concordance between GenomeStudio calls and Z-call for threshold file: " $basename_c".output.thresholds.txt"
	python ${zcall_path}/calibrateZ.py -R ${data_path}/${basename}".report" -T ${basename_c}".output.thresholds.txt" > ${basename_c}".output.thresholds.txt".stats
	
	#cleanup
	#rm $basename_c".mean.sd.txt"
	#rm $basename_c".betas.txt" 
	
	
	#5) plot and calc optimal calibration
	pushd .
	cd ../R_z-calib
	Rscript global_concordance.R
	popd
	
	echo "Finished: "`date`
fi

######################################################################################################################################

#scenario 2

# If a threshold file was provided as an arg then jump straight to z calling
#4) Re-call with zcall all No Call (NC) SNPS from Gencall 
echo "4) Re-calling the No Call (NC) SNPS with zcall"
echo call: python ${zcall_path}/zCall.py -R ${data_path}/${basename}".report" -T ${thresholdfile} -O ${basename}".tped_tfam"
python ${zcall_path}/zCall.py -R ${data_path}/${basename}".report" -T ${thresholdfile} -O ${basename}".tped_tfam"
echo "Finished: "`date`


