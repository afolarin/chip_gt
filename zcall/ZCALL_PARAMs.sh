#!/bin/sh

#--------------------------------------------------------------------------#
# ************************** FOR RUNNING ZCALL *************************** #
# *********** DEFINE PARAMETERS HERE FOR RUNNING SGE JOBS **************** # 
#--------------------------------------------------------------------------#

# PARAM 1: 
# Define of the PATH VARIABLE for the relevant Z-Call Executable, 
# this will be sourced by all the calling scripts to define 
# Alternatively, the variable can be populated in the shell if preferred 
zcall_path="/share/apps/zcall_current/Version3_GenomeStudio/bin"


# PARAM 2:
# Enter here the base name of the Illuminal Genome Studio Report <basename>.report file
#basename="moorfields_191112_zCall_01"
#basename="moorfields_191112_zCall_01_filt"
basename="moorfields_191112_zCall_01_filt_faster-version.report"



# PARAM 3
# Enter the location of the Report File
data_path=`pwd`

# PARAM 4
# Z=7

# PARAM 5
# I=0.2
