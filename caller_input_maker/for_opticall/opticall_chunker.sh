#########################################################################
# -- Author: Amos Folarin                                               #
# -- Organisation: KCL/SLaM                                             #
# -- Email: amosfolarin@gmail.com                                       #
#########################################################################

## Create chromosome chunks from the Genome Studio file with the format
## Name<tab>Chr<tab>Position<tab>Sample1.GType<tab>Sample1.X<tab>Sample1.Y

# USAGE: opticall_chunker.sh <genome-studio-report_file>
# OUTPUT: 1 file per chromosome

# ARGS: 
inFile=$1
outFile=$2

#------------------------------------------------------------------------
# Create chunk files by chromosome
#------------------------------------------------------------------------
declare -a chrs=("1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "X" "Y" "XY" "MT")

for i in ${chrs[@]}
do
	#take the header
	awk -v i=${i} '(NR == 1) {print $0}' ${inFile} > ${outFile}"_Chr_${i}"
	#print the whole row where Chr field ($2) == chr i
	awk -v chromosome=${i} '($2 == chromosome)  {print $0}' ${inFile} >> ${outFile}"_Chr_${i}"

done
