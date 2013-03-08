#!/bin/sh
#$ -S /bin/sh
#$ -N plink.genome.sh
#$ -l h_vmem=10G
#$ -q long.q,short.q
#$ -p -0.99
#$ -pe multi_thread 1
#$ -j yes
#$ -cwd
############################

plink --bfile ${1} --genome --out ${1} --min 0.05 --max 1;
cat ${1}.genome | awk '$10>0.1875 '  > ${1}.genome.PI_HAT.rel_sample;
