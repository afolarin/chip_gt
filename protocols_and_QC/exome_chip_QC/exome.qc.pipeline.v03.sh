#!/bin/sh
#$ -S /bin/sh
#$ -N exome.qc.pipeline.v03.sh
#$ -l h_vmem=10G
#$ -q long.q,short.q
#$ -p -0.99
#$ -pe multi_thread 1
#$ -j yes
#$ -cwd
#$ -V
############################

pedfile=${1} #input file
bedfile=${2} #output name

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
## qsub plink.genome.sh ${bedfile}_03_LDpruned;
plink --bfile ${bedfile}_03_LDpruned --genome --out ${bedfile}_03_LDpruned --min 0 --max 1;
cat ${bedfile}_03_LDpruned.genome | awk '$10>0.1875 '  > ${bedfile}_03_LDpruned.genome.PI_HAT.rel_sample;
cat ${bedfile}_03_LDpruned.genome.PI_HAT.rel_sample | sed '1,1d' | awk '{print $3,$4}' > ${bedfile}_03_LDpruned.genome.PI_HAT.rel_sample_exclude;
#plink --noweb --bfile ${bedfile}_03_LDpruned  --out ${bedfile}_04_LDpruned --remove ${bedfile}_03_LDpruned.genome.PI_HAT.rel_sample_exclude;
cat *sample*exclude | sort | uniq > final_sample_exclude;

#only want 2nd column, i.e. sample ids., ok to clobber
cat final_sample_exclude | awk '{print $2}' > final_sample_exclude
