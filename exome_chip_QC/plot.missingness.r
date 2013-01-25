## Plots ##
data_dir <- getwd()
setwd(data_dir)
bfile="plink"
# get args
t=commandArgs()
if (charmatch("--args",t,nomatch=-1)>=0) args = t[((1:length(t))[t=="--args"]+1):length(t)] else args=""
if (charmatch("bfile=",args,nomatch=-1)>=0) bfile = strsplit(args[charmatch("bfile=",args)],split="=")[[1]][2]
pdf("missingness.01.pdf")
IMISS=read.table(paste(bfile,".imiss",sep=""), header=T, as.is=T);
LMISS=read.table(paste(bfile,".lmiss",sep=""), header=T, as.is=T);
LMISS=subset(LMISS,!is.na(LMISS$F_MISS))
oldpar=par(mfrow=c(1,2));
plot( (1:dim(IMISS)[1])/(dim(IMISS)[1]-1), sort(1-IMISS$F_MISS), 
main="Individual call rate cumulative distribution", xlab="Quantile", ylab="Call Rate" ); 
grid()
plot( (1:dim(LMISS)[1])/(dim(LMISS)[1]-1), sort( 1-LMISS$F_MISS ), 
main="SNP coverage cumulative distribution", xlab="Quantile", ylab="Coverage"); 
grid()
par(oldpar);
dev.off();
