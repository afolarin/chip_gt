#########################################################################
# -- Author: Amos Folarin                                               #
# -- Organisation: KCL/SLaM                                             #
# -- Email: amosfolarin@gmail.com                                       #
#########################################################################


#RScript to plot out the Global Concordance from the ZCall Calibration statistics files
# USAGE: from R_z-calib dir, run:
#        Rscript globalconcordance.R
# OUTPUT: 1) pdf file plot of global concordance vs z range(3-15)
#         2) file optimal.thresh a file listing the optimal threshold 

# ARGS:
args <- commandArgs(TRUE)
setwd(args[1])


#stat.f <- dir(path="../calibrateZ_out/", pattern=".*stats")
stat.f <- dir(path="./", pattern=".*stats")

zscore <- c()
global.conc <- c() 

for (f in stat.f)
{
        #tmp <- readLines(paste("../calibrateZ_out/", f, sep=""))
        tmp <- readLines(paste("./", f, sep=""))
        conc <- as.numeric(substr( tmp[4], 21, nchar(tmp[4])))
        global.conc <- append(global.conc, conc)
        z.ind <- regexpr(pattern="z=(\\d)+", f)
        start <- z.ind[1]
        end <- attr(z.ind, "match.length")
        z <- as.numeric(substr(f, start+2, start+(end-1)))
        zscore <- append(zscore, z)
}



gc.df <- data.frame(zscore, global.conc)
gc.df <- gc.df[sort.list(gc.df$zscore), ]

pdf(file="zscore-vs-global.concordance.pdf")
plot(gc.df$zscore, gc.df$global.conc, type="b", main="Z-Call Calibration", sub="Global Concordance of Gencall and Z-Call")
dev.off()


best.thresh.file <- stat.f[which.max(global.conc)]
len.s <- nchar(best.thresh.file)
best.thresh.file <- substr(best.thresh.file, 1, len.s -6)
#echo stat file which resulted in optimal concordance to stdout
#print("**************************************************************************************")
#print("The following file has the optimal concordance, use the Z value given in the filename:")
#print(best.thresh.file)
#print("**************************************************************************************")

write.table(file="optimal.thresh", x=best.thresh.file,row.names=F,col.names=F,quote=F)

#return to s/o name of best threshold file
print(best.thresh.file)
