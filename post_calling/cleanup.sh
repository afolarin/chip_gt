#!/bin/bash

#########################################################################
# -- Author: Amos Folarin                                               #
# -- Organisation: KCL/SLaM                                             #
# -- Email: amosfolarin@gmail.com                                       #
#########################################################################

#------------------------------------------------------------------------
# DESCRIPTION:
# Fairly drastic removal of all intermediate files from the exome chip 
# pipeline run. This will only keep the endpoints of zcall and opticall! 
# For a list of what will be kept after running this script
#  see: the list in file "Pipeline_Report.txt"
#------------------------------------------------------------------------

#------------------------------------------------------------------------
# USAGE: from the working directory containing all the output from the  
# bash cleanup.sh <<basename_of_reportfile>>  
# e.g. bash cleanup.sh my_report_file   # note no .report
# 
#------------------------------------------------------------------------

# ARGS:
basename=${1}


#------------------------------------------------------------------------
# Give the user a commandline option to clean-up the directory of intermediate files
# after the run. 
#------------------------------------------------------------------------
echo "Do you want to run the cleanup script? "
echo "Answer: yes / no"
read answer
while [ ${answer}!= "yes" || $answer != "no" ]
do
        echo "Answer: yes / no"
        read answer

done

if (( $answer == "yes" ))
then

        echo "WARNING! this will get rid of all intermediate files from the run"
	echo "i.e. you will only be left with these files:"
	echo "${basename}_filt_opticall-cat.calls"
        echo "${basename}_filt_Opticall.tped" 
	echo "${basename}_filt_Opticall_UA.bed"
        echo "${basename}_filt_Opticall_UA.bim"
	echo "${basename}_filt_Opticall_UA.fam"
        echo "${basename}_filt_Zcalls.tped"
	echo "${basename}_filt_Zcalls_UA.bed"
        echo "${basename}_filt_Zcalls_UA.bim"
	echo "${basename}_filt_Zcalls_UA.fam""

        echo "SURE YOU WANT TO DO THIS?"
        echo "Answer: yes / no"

        read answer2
        echo "Answer: yes / no"

        while [ ${answer}!= "yes" || $answer != "no" ]
        do
                echo "Answer: yes / no"
                read answer

        done

        if (( $answer2 == "yes" ))
        then
                
                echo $answer2
                removeList=xargs -0 ls <<< "-I ${basename}_filt_opticall-cat.calls \
                -I ${basename}_filt_Opticall.tped -I ${basename}_filt_Opticall_UA.bed \
                -I ${basename}_filt_Opticall_UA.bim -I ${basename}_filt_Opticall_UA.fam \
                -I ${basename}_filt_Zcalls.tped -I ${basename}_filt_Zcalls_UA.bed \
                -I ${basename}_filt_Zcalls_UA.bim -I ${basename}_filt_Zcalls_UA.fam"
                xargs -0 rm <<< ${removeList}

        fi

fi
