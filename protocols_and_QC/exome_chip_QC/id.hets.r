###############################################################################################################
## id.hets.r ##################################################################################################
##############################################################################################################
data_dir <- getwd()
setwd(data_dir)
# default
bfile="plink.het"
sdcut=3
# get args
t=commandArgs()
if (charmatch("--args",t,nomatch=-1)>=0) args = t[((1:length(t))[t=="--args"]+1):length(t)] else args=""
if (charmatch("bfile=",args,nomatch=-1)>=0) bfile = strsplit(args[charmatch("bfile=",args)],split="=")[[1]][2]
if (charmatch("sdcut=",args,nomatch=-1)>=0) sdcut = strsplit(args[charmatch("sdcut=",args)],split="=")[[1]][2]
##
d <- read.table(bfile,head=T);
het_outliers_3sd <- abs(scale(d$F))>3
write.table(d[het_outliers_3sd,],file="het_outliers.txt",sep="\t",quote=F,row.names=F);
write.table(d[het_outliers_3sd,c(1,2)],file="het_outliers_sample_exclude",sep="\t",quote=F,row.names=F,col.names=F);

