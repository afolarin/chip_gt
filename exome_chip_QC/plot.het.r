
## plot.het.r
## R --vanilla --slave --args bfile=${bedfile}_01 < plot.het.r;
data_dir <- getwd()
setwd(data_dir)
bfile="plink.het"
# get args
t=commandArgs()
if (charmatch("--args",t,nomatch=-1)>=0) args = t[((1:length(t))[t=="--args"]+1):length(t)] else args=""
if (charmatch("bfile=",args,nomatch=-1)>=0) bfile = strsplit(args[charmatch("bfile=",args)],split="=")[[1]][2]
HET=read.table(bfile, header=T, as.is=T)
H = (HET$N.NM.-HET$O.HOM.)/HET$N.NM.
pdf("het.pdf")
oldpar=par(mfrow=c(1,2))
hist(H,50)
hist(HET$F,50)
par(oldpar)
HET[order(HET$F),]
#
boxplot(HET$F)
dev.off()
