#!/bin/sh
#$-S /bin/sh
#$-cwd
#$ -V

#########################################################################
# -- Author: Amos Folarin                                               #
# -- Organisation: KCL/SLaM                                             #
# -- Email: amosfolarin@gmail.com                                       #
#########################################################################


######################################################################
# The QC steps run prior to running Zcall may have produced a list of samples to drop
# remove the list of bad samples from the Report file prior to carrying out Zcall
# ARGS:
# arg1: basename (filename root of GenomeStudio report file in working directory)
# arg2: file containing a list of samples to drop
# dropSamplesFromPReport.py is a utility script to drop samples from an Illumina GenomeStudio report. 
# Inputs: are the report and a text file with samples to drop (one sample per line). Sample name is the same as the root before the ".GType"
# Output: a report file with the list of samples filtered out <basename>.filt.report

#USAGE: qsub -q <queue.q> sge_dropBadSamples.sh <basename> <SampleDropListFile>
######################################################################

#args
basename=${1}
dropList=${2}

#duplicate the report file in the cwd (a safty feature, keep local original uncleaned file)
cp ${basename}.report ${basename}_dup.report

# call dropSamplesFromReport.py
dropSamplesFromReport_FasterVersion.py ${basename}_dup.report ${dropList} > ${basename}_filt.report

