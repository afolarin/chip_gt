#!/bin/sh
#$ -S /bin/sh
#$ -l h_vmem=10G
#$ -pe multi_thread 1
#$ -j yes
#$ -cwd
#$ -V
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

plink --noweb --bfile ${bedfile}_03 --indep-pairwise 500 50 0.50 --maf 0.05 --out ${bedfile}_03;

plink --noweb --bfile ${bedfile}_03 --make-bed --maf 0.05 --geno 0.10 --out ${bedfile}_03_LDpruned --extract ${bedfile}_03.prune.in;

## 9 Het 
echo "- het -"

plink --noweb --bfile ${bedfile}_03_LDpruned --het --maf 0.05 --geno 0.10 --out ${bedfile}_03_LDpruned;

Rscript removehets.R ${bedfile}_03_LDpruned.het;

## produces ${bedfile}_03_LDpruned.het.het.sample.remove

mv ${bedfile}_03_LDpruned.het.het.sample.remove  het_outliers_sample_exclude

## 10 Cryptic relatedness --Z-genome " 

plink \
--noweb \
--bfile ${bedfile}_03_LDpruned \
--allow-no-sex \
--out ${bedfile}_03_LDpruned \
--Z-genome;

zcat ${bedfile}_03_LDpruned.genome.gz | awk '$10>0.1875' >   ${bedfile}_03_LDpruned.genome.related;

cat  ${bedfile}_03_LDpruned.genome.related | awk '{print $1"\t"$2}' > ${bedfile}_03_LDpruned.genome.related.sample.remove;

mv ${bedfile}_03_LDpruned.genome.related.sample.remove related_sample_exclude;


### FINAL LIST OF BAD SAMPLES

cat *sample_callrate_exclude >> final_sample_callrate_exclude

cat final_sample_callrate_exclude related_sample_exclude het_outliers_sample_exclude | awk '{print $2}' | sort | uniq > final_sample_exclude;




























