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
plink --noweb --file ${pedfile} --make-bed --out ${bedfile}.plinkQC_01;


## grep Duplicate ${bedfile}.plinkQC_01.log | awk '{print $5,$6}' > ${bedfile}.plinkQC_01.duplicate.samples;

## 2 run very basic qc
echo "- running basic qc 01 -"
for my_qc in missing freq hardy;do
plink --noweb --bfile ${bedfile}.plinkQC_01 --${my_qc} --out ${bedfile}.plinkQC_01;
done

## Plot missing
R --vanilla --slave --args bfile=${bedfile}.plinkQC_01 < plot.missingness.r;


## 3 Id samples/SNPs with call rates <= 90%
cat ${bedfile}.plinkQC_01.imiss | awk '$6>=0.10'> ${bedfile}.plinkQC_01_poor_sample_callrate;
cat ${bedfile}.plinkQC_01.imiss | awk '$6>=0.10'| sed '1,1d' | awk '{print $1,$2}' > ${bedfile}.plinkQC_01_poor_sample_callrate_exclude;
#
cat ${bedfile}.plinkQC_01.lmiss | awk '$5>=0.10'> ${bedfile}.plinkQC_01_poor_snp_callrate;
cat ${bedfile}.plinkQC_01.lmiss | awk '$5>=0.10'| sed '1,1d' | awk '{print $1,$2}' > ${bedfile}.plinkQC_01_poor_snp_callrate_exclude;

## 3.1 list of COMMON SNPS
cat ${bedfile}.plinkQC_01.frq | awk '$5>=0.05'> ${bedfile}.plinkQC_01_common_snps;
cat ${bedfile}.plinkQC_01.frq | awk '$5>=0.05' | sed '1,1d' | awk '{print $2}' > ${bedfile}.plinkQC_01_common_snps_list;
cat ${bedfile}.plinkQC_01.frq | awk '$5<0.05' | sed '1,1d' | awk '{print $2}' > ${bedfile}.plinkQC_01_rare_snps_list;

## 4 remove samples/snps from orig bed with call rates <= 90%.
echo "- remove samples with call rate < 90% -"
echo "- remove snps with call rate < 90% -"

plink --noweb \
--bfile ${bedfile}.plinkQC_01 \
--make-bed \
--out ${bedfile}.plinkQC_02 \
--remove ${bedfile}.plinkQC_01_poor_sample_callrate_exclude \
--exclude ${bedfile}.plinkQC_01_poor_snp_callrate_exclude;


## 5 basic QC on data ${bedfile}.plinkQC_02 - data with poor sample call rates removed
for my_qc in missing freq hardy;do
plink --noweb --bfile ${bedfile}.plinkQC_02 --${my_qc} --out ${bedfile}.plinkQC_02;
done

## 6 id samples < 98%
cat ${bedfile}.plinkQC_02.imiss | awk '$6>=0.02'> ${bedfile}.plinkQC_02_poor_sample_callrate;
cat ${bedfile}.plinkQC_02.imiss | awk '$6>=0.02'| sed '1,1d' | awk '{print $1,$2}' > ${bedfile}.plinkQC_02_poor_sample_callrate_exclude;
cat ${bedfile}.plinkQC_02.frq | awk '$5>=0.05'> ${bedfile}.plinkQC_02_common_snps;
cat ${bedfile}.plinkQC_02.frq | awk '$5>=0.05' | sed '1,1d' | awk '{print $2}' > ${bedfile}.plinkQC_02_common_snps_list;
cat ${bedfile}.plinkQC_02.frq | awk '$5<0.05' | sed '1,1d' | awk '{print $2}' > ${bedfile}.plinkQC_02_rare_snps_list;

## 7 remove samples < 98%
echo "- remove samples with call rate < 98% -"
plink --noweb --bfile ${bedfile}.plinkQC_02 --make-bed --out ${bedfile}.plinkQC_03 --remove ${bedfile}.plinkQC_02_poor_sample_callrate_exclude;

## 8 ld prune for --het, --genome and PCA
echo "- ld prune -"

plink --noweb --bfile ${bedfile}.plinkQC_03 --indep-pairwise 500 50 0.50 --maf 0.05 --out ${bedfile}.plinkQC_03;

plink --noweb --bfile ${bedfile}.plinkQC_03 --make-bed --maf 0.05 --geno 0.10 --out ${bedfile}.plinkQC_03_LDpruned --extract ${bedfile}.plinkQC_03.prune.in;

## 9 Het 
echo "- het -"

plink --noweb --bfile ${bedfile}.plinkQC_03_LDpruned --het --maf 0.05 --geno 0.10 --out ${bedfile}.plinkQC_03_LDpruned;

Rscript removehets.R ${bedfile}.plinkQC_03_LDpruned.het;

## produces ${bedfile}.plinkQC_03_LDpruned.het.het.sample.remove

mv ${bedfile}.plinkQC_03_LDpruned.het.het.sample.remove  het_outliers_sample_exclude

## 10 Cryptic relatedness --Z-genome " 

plink \
--noweb \
--bfile ${bedfile}.plinkQC_03_LDpruned \
--allow-no-sex \
--out ${bedfile}.plinkQC_03_LDpruned \
--Z-genome;

zcat ${bedfile}.plinkQC_03_LDpruned.genome.gz | awk '$10>0.1875' >   ${bedfile}.plinkQC_03_LDpruned.genome.related;

cat  ${bedfile}.plinkQC_03_LDpruned.genome.related | awk '{print $1"\t"$2}' > ${bedfile}.plinkQC_03_LDpruned.genome.related.sample.remove;

mv ${bedfile}.plinkQC_03_LDpruned.genome.related.sample.remove related_sample_exclude;


### FINAL LIST OF BAD SAMPLES

cat *sample_callrate_exclude >> final_sample_callrate_exclude

cat final_sample_callrate_exclude related_sample_exclude het_outliers_sample_exclude | awk '{print $2}' | sort | uniq > final_sample_exclude;




























