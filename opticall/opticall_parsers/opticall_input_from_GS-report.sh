#!/bin/sh

#########################################################################
# -- Author: Amos Folarin                                               #
# -- Organisation: KCL/SLaM                                             #
# -- Email: amosfolarin@gmail.com                                       #
#########################################################################

## INPUT: Take either whole Genome Studio report files or report chunked by
## chromosome. see opticall_chunker.sh

## OUTPUT: Builds opticall input from a Genome Studio Report file with the format
## Name<tab>Chr<tab>Position<tab>Sample1.GType<tab>Sample1.X<tab>Sample1.Y
## File format output - [SNP] [Coor] [Alleles] [SampleA [intX] [intY]] [SampleN [intX] [intY]]

## USAGE: bash ./opticall_input_from_GS-report.sh <genomeStudioReport>


#PARAMS:
gsReport=${1}
outputFile=${1}"_opticall-in"

# Alleles column is essentially a constant AB, as intX == A and intY == B

# Header
perl -lane '$,="\t"; @intensities=(); for($i=3; $i<=$#F; $i++){ if($i%3 != 0) {push(@intensities, $i);}} if($. == 0) { print("SNP",  "Coor",  "Alleles",  "@F[@intensities]");}' ${gsReport} > ${outputFile}

# Build the file, dropping Chr and Genotype cols.. adding the Allele column for 2nd row to end-of-file
perl -lane '$,="\t"; @intensities=(); for($i=3; $i<=$#F; $i++){ if($i%3 != 0) {push(@intensities, $i);}} if($. != 0) { print($F[0],  $F[2],  "AB",  "@F[@intensities]");}' ${gsReport} > ${outputFile}

