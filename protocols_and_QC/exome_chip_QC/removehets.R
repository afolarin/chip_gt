#!/share/bin/Rscript

args <- commandArgs(trailingOnly=TRUE);

het_file <- args[1];

# read data in
HET=read.table(paste(het_file,sep=""), header=T, as.is=T);

H <- (HET$N.NM.-HET$O.HOM.)/HET$N.NM.;
F <- HET$F;
F_Z <- scale(F);
H_Z <- scale(H);
# start plots
pdf_file <- paste(het_file,".pdf",sep="");

pdf(pdf_file,width=8,height=6)
oldpar=par(mfrow=c(1,2))
hist(H,50)
hist(F,50)
boxplot(H,main="H")
boxplot(F,main="F")
hist(H_Z,50)
hist(F_Z,50)
boxplot(H_Z,main="H_Z")
boxplot(F_Z,main="F_Z")
plot(H,F)
plot(H_Z,F_Z)
par(oldpar)
dev.off()

# id outliers

samples_remove_file <- paste(het_file, ".sample.remove",sep="");

het_out <- ( abs(F_Z) > 3 );

samples_remove <- HET[het_out,];

# write to file for plink --remove
write.table(samples_remove[,c("FID","IID")], file=samples_remove_file, col.names=FALSE, row.names=FALSE, sep="\t", quote=FALSE);

# DONE !!!


