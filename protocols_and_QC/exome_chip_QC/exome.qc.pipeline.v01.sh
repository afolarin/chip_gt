#!/bin/sh
#$ -S /bin/sh
#$ -N exome.qc.pipeline.v01.sh
#$ -l h_vmem=10G
#$ -q long.q,short.q
#$ -p -0.99
#$ -pe multi_thread 1
#$ -j yes
#$ -cwd
############################

pedfile=${1}
bedfile=${2}

## 1 GenomeStudio PLINK ped file to PLINK Binary
echo "- convert ped to bed -"
plink --noweb --file ${pedfile} --make-bed --out ${bedfile}_01;
## grep Duplicate ${bedfile}_01.log | awk '{print $5,$6}' > ${bedfile}_01.duplicate.samples;

## 2 run very basic qc
echo "- running basic qc 01 -"
for my_qc in missing freq hardy;do
plink --noweb --bfile ${bedfile}_01 --${my_qc} --out ${bedfile}_01;
done
## Plot missing
R --vanilla --slave --args bfile=${bedfile}_01 < plot.missingness.r;


## 3 Id samples/SNPs with call rates <= 90%
cat ${bedfile}_01.imiss | awk '$6>=0.10'> ${bedfile}_01_poor_sample_callrate;
cat ${bedfile}_01.imiss | awk '$6>=0.10'| sed '1,1d' | awk '{print $1,$2}' > ${bedfile}_01_poor_sample_callrate_exclude;
#
cat ${bedfile}_01.lmiss | awk '$5>=0.10'> ${bedfile}_01_poor_snp_callrate;
cat ${bedfile}_01.lmiss | awk '$5>=0.10'| sed '1,1d' | awk '{print $1,$2}' > ${bedfile}_01_poor_snp_callrate_exclude;

## 3.1 list of COMMON SNPS
cat ${bedfile}_01.frq | awk '$5>=0.05'> ${bedfile}_01_common_snps;
cat ${bedfile}_01.frq | awk '$5>=0.05' | sed '1,1d' | awk '{print $2}' > ${bedfile}_01_common_snps_list;
cat ${bedfile}_01.frq | awk '$5<0.05' | sed '1,1d' | awk '{print $2}' > ${bedfile}_01_rare_snps_list;

## 4 remove samples/snps from orig bed with call rates <= 90%.
echo "- remove samples with call rate < 90% -"
echo "- remove snps with call rate < 90% -"
plink --noweb \
--bfile ${bedfile}_01 \
--make-bed \
--out ${bedfile}_02 \
--remove ${bedfile}_01_poor_sample_callrate_exclude \
--exclude ${bedfile}_01_poor_snp_callrate_exclude;


## 5 basic QC on data ${bedfile}_02 - data with poor sample call rates removed
for my_qc in missing freq hardy;do
plink --noweb --bfile ${bedfile}_02 --${my_qc} --out ${bedfile}_02;
done

## 6 id samples < 98%
cat ${bedfile}_02.imiss | awk '$6>=0.02'> ${bedfile}_02_poor_sample_callrate;
cat ${bedfile}_02.imiss | awk '$6>=0.02'| sed '1,1d' | awk '{print $1,$2}' > ${bedfile}_02_poor_sample_callrate_exclude;
cat ${bedfile}_02.frq | awk '$5>=0.05'> ${bedfile}_02_common_snps;
cat ${bedfile}_02.frq | awk '$5>=0.05' | sed '1,1d' | awk '{print $2}' > ${bedfile}_02_common_snps_list;
cat ${bedfile}_02.frq | awk '$5<0.05' | sed '1,1d' | awk '{print $2}' > ${bedfile}_02_rare_snps_list;

## 7 remove samples < 98%
echo "- remove samples with call rate < 98% -"
plink --noweb --bfile ${bedfile}_02 --make-bed --out ${bedfile}_03 --remove ${bedfile}_02_poor_sample_callrate_exclude;

## 8 ld prune for --het, --genome and PCA
echo "- ld prune -"
plink --noweb --bfile ${bedfile}_03 --indep-pairwise 1500 150 0.50 --maf 0.05 --out ${bedfile}_03;
plink --noweb --bfile ${bedfile}_03 --make-bed --maf 0.05 --geno 0.10 --out ${bedfile}_03_LDpruned --extract ${bedfile}_03.prune.in;

## 9 Het 
echo "- het -"
plink --noweb --bfile ${bedfile}_03_LDpruned --het --maf 0.05 --geno 0.10 --out ${bedfile}_03_LDpruned;

#################################################
## R id het > 3sd from mean abs(F)
#################################################
## to do
## het_cut=${3}; R --vanilla --slave --args sdcut=${het_cut} bfile=${bedfile}_03_LDpruned.het < id.hets.r;

R --vanilla --slave --args sdcut=3 bfile=${bedfile}_03_LDpruned.het < id.hets.r;
R --vanilla --slave --args bfile=${bedfile}_03_LDpruned.het < plot.het.r;
## produces : het_outliers_sample_exclude

## 10 genome ; run as sep sge job as this can take a loooong time!
qsub plink.genome.sh ${bedfile}_03_LDpruned;

## 11 PCA 
## PCA using EIGENSOFTplus_v12.r
cp -v ${bedfile}_03_LDpruned.bim ${bedfile}_03_LDpruned_4pca.bim;
cp -v ${bedfile}_03_LDpruned.fam ${bedfile}_03_LDpruned_4pca.fam;
cp -v ${bedfile}_03_LDpruned.bed ${bedfile}_03_LDpruned_4pca.bed;
perl -p -i -e 's/-9/1/g' ${bedfile}_03_LDpruned_4pca.fam;
##
awk '{print $1,$2,1}' ${bedfile}_03_LDpruned_4pca.fam > ${bedfile}_03_LDpruned_4pca.phe;
## NB: ESOFTdir="/share/bin"                #Sets the location of the EIGENSOFT directory
## EIGENSOFTplus_v12.r
R --vanilla --slave --args \
stem=${bedfile}_03_LDpruned_4pca \
altnormstyle=N0 \
numoutevec=10 \
numoutlieriter=1 \
nsnpldregress=5 \
noxdata=YES \
numgamma=10 \
numplot=10 \
numoutlierevec=10 \
outliersigmathresh=6 \
gamplot=YES \
heatplot=YES  < EIGENSOFTplus_v12.r;
## to do
## make list of all samples that fail qc
## make list of BAD SNPS < 90% == ${bedfile}_01_poor_snp_callrate_exclude;
## output from PCA needs 

