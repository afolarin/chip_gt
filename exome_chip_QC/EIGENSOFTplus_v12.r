#EIGENSOFTplus_v12.txt
#version 12: Add option to evoke EIGENSOFT's own option to output "SNP weightings"
#version 11: Add 'nice' to slow calls
#version 10: Add output file of kmeans0 and kmeans4 SNP loadings
#performs EIGENSOFT, calculates SNP loadings, produces some useful plots
#R --vanilla --slave --args stem=plink altnormstyle=N0 numoutevec=10 numoutlieriter=0 nsnpldregress=0 noxdata=YES numgamma=10 numplot=10 gamplot=NO heatplot=NO ESOFTdir=/research/labs/goldsteinlab/software/EIGENSOFT < /research/labs/goldsteinlab/Mike/Docs/EIGENSOFTplus/ver10/EIGENSOFTplus.txt
#All args following "--args" and before "<" are optional - their default values are as shown above


#Option list: defaults
stem="plink"                    #Sets the stemname for .bed, .bim and .fam files
altnormstyle="N0"
numoutevec=10                   #Sets the number of axes for which indiv scores are calculated
numoutlieriter=0                #sets maximum number of outlier removal iterations (0 turns off, 5 = original default)
nsnpldregress=0 
noxdata="YES" 
numgamma=10                     #Sets the number of axes for which SNP loadings are calculated (strictly, will be min(numgamma,numoutevec)
numplot=10                      #Sets the number of axes for which plots calculated (strictly, will be min(numgamma,numoutevec,numplot) for Q-Q plot and min(numoutevec,numplot) for histogram)
gamplot="NO"                    #If "yes" then plot SNP loadings for PC1 against physical position
heatplot="NO"                   #If "yes" then plot "heatmap" of genotypes for each individual
ESOFTdir="/share/apps/eigensoft_3.0"  #Sets the location of the EIGENSOFT directory
numoutlierevec=10               #number of principal components along which to remove outliers during each outlier removal iteration
outliersigmathresh=6            #number of standard deviations which an individual must exceed, along one of the top (numoutlierevec) PC's, in order for that individual to be removed as an outlier
kmeans="NO"                     #Option to perform kmeans analysis (for "inversion" regions)
snpweightout="NO"               #Option to call EIGENSOFT's SNP loading option

#args=c("stem=test","numgamma=2")  #use for debuggging
#Override with args if set
t=commandArgs()
if (charmatch("--args",t,nomatch=-1)>=0) args = t[((1:length(t))[t=="--args"]+1):length(t)] else args=""
if (charmatch("stem=",args,nomatch=-1)>=0) stem = strsplit(args[charmatch("stem=",args)],split="=")[[1]][2]
if (charmatch("altnormstyle=",args,nomatch=-1)>=0) altnormstyle = strsplit(args[charmatch("altnormstyle=",args)],split="=")[[1]][2]
if (charmatch("numoutevec=",args,nomatch=-1)>=0) numoutevec = as.numeric(strsplit(args[charmatch("numoutevec=",args)],split="=")[[1]][2])
if (charmatch("numoutlieriter=",args,nomatch=-1)>=0) numoutlieriter = as.numeric(strsplit(args[charmatch("numoutlieriter=",args)],split="=")[[1]][2])
if (charmatch("nsnpldregress=",args,nomatch=-1)>=0) nsnpldregress = as.numeric(strsplit(args[charmatch("nsnpldregress=",args)],split="=")[[1]][2])
if (charmatch("noxdata=",args,nomatch=-1)>=0) noxdata = strsplit(args[charmatch("noxdata=",args)],split="=")[[1]][2]
if (charmatch("numgamma=",args,nomatch=-1)>=0) numgamma = as.numeric(strsplit(args[charmatch("numgamma=",args)],split="=")[[1]][2])
if (charmatch("numplot=",args,nomatch=-1)>=0) numplot = as.numeric(strsplit(args[charmatch("numplot=",args)],split="=")[[1]][2])
if (charmatch("gamplot=",args,nomatch=-1)>=0) gamplot = strsplit(args[charmatch("gamplot=",args)],split="=")[[1]][2]
if (charmatch("heatplot=",args,nomatch=-1)>=0) heatplot = strsplit(args[charmatch("heatplot=",args)],split="=")[[1]][2]
if (charmatch("ESOFTdir=",args,nomatch=-1)>=0) ESOFTdir = strsplit(args[charmatch("ESOFTdir=",args)],split="=")[[1]][2]
if (charmatch("numoutlierevec=",args,nomatch=-1)>=0) numoutlierevec = as.numeric(strsplit(args[charmatch("numoutlierevec=",args)],split="=")[[1]][2])
if (charmatch("numoutlierevec=",args,nomatch=-1)>=0) numoutlierevec = as.numeric(strsplit(args[charmatch("numoutlierevec=",args)],split="=")[[1]][2])
if (charmatch("outliersigmathresh=",args,nomatch=-1)>=0) outliersigmathresh = as.numeric(strsplit(args[charmatch("outliersigmathresh=",args)],split="=")[[1]][2])
if (charmatch("kmeans=",args,nomatch=-1)>=0) kmeans = strsplit(args[charmatch("kmeans=",args)],split="=")[[1]][2]
if (charmatch("snpweightout=",args,nomatch=-1)>=0) snpweightout = strsplit(args[charmatch("snpweightout=",args)],split="=")[[1]][2]


#Save output also to text file
sink(file=paste(stem,".Rout",sep=""),type="output",split=TRUE)


#make copies of .bim and .fam files, Create .par file with same stem name
print("Reading arguments...")
system(paste("cp ",stem,".bim ",stem,".pedsnp",sep=""))
system(paste("cp ",stem,".fam ",stem,".pedind",sep=""))
FID = file(paste(stem,".par",sep=""),"w")
writeLines(paste("genotypename:    ",stem,".bed",sep=""),FID)
writeLines(paste("snpname:         ",stem,".pedsnp",sep=""),FID)
writeLines(paste("indivname:       ",stem,".pedind",sep=""),FID)
writeLines(paste("evecoutname:     ",stem,".evec",sep=""),FID)
writeLines(paste("evaloutname:     ",stem,".eval",sep=""),FID)
writeLines(paste("altnormstyle:    ",altnormstyle,sep=""),FID)
writeLines(paste("numoutevec:      ",as.character(numoutevec),sep=""),FID)
writeLines(paste("numoutlieriter:  ",as.character(numoutlieriter),sep=""),FID)
writeLines(paste("nsnpldregress:   ",as.character(nsnpldregress),sep=""),FID)
writeLines(paste("noxdata:         ",noxdata,sep=""),FID)
writeLines(paste("numoutlierevec:  ",as.character(numoutlierevec),sep=""),FID)
writeLines(paste("outliersigmathresh:  ",as.character(outliersigmathresh),sep=""),FID)
writeLines(paste("outlieroutname:  ",stem,".outliers",sep=""),FID)
writeLines(paste("phylipoutname:   ",stem,".fst",sep=""),FID)
if (snpweightout=="YES") writeLines(paste("snpweightoutname:   ",stem,".load",sep=""),FID)
close(FID)


#Call EIGENSOFT
print("Calling EIGENSOFT...")
system(paste("nice ", ESOFTdir, "/bin/smartpca -p ", stem, ".par > ", stem, ".Sout", sep=""))


#Call TWstats
print("Calling TWstats...")
system(paste("nice ", ESOFTdir, "/bin/twstats -t ", ESOFTdir, "/POPGEN/twtable -i ", stem, ".eval >>  ", stem, ".Sout", sep=""))


#Read in values from .evec file
pcafile = paste(stem,".evec",sep="")
  FIDpca = file(pcafile,"r")
  lambda = strsplit(readLines(FIDpca,n=1),split=" +")[[1]] [c(-1,-2)]  #Note " +" means match any number of spaces
  NNaxes = length(lambda)
  eigvec = as.matrix( read.table(FIDpca,header=FALSE,row.names=1,comment.char="",colClasses=c("character",rep("numeric",NNaxes),"NULL")) )
  close(FIDpca)


#Plot histograms on PCA scores
Naxes = min(NNaxes,numoutevec,numplot)
if (Naxes>0) {
  print("Creating histogram plots...")
  pdf(paste(stem,"_hist.pdf",sep=""))
  oldpar = par(mfrow=c(ceiling(Naxes/2),1+(Naxes>1)), oma=c(.5,.5,.5,.5), cex.lab=.2, mex=.2, tck=-0.02)
  for (i in 1:Naxes) {
    hist(eigvec[,i],75, main=paste("PC",as.character(i)))
  }
  par(oldpar)
  dev.off()
}

#Save outlier individuals for plotted histograms (ordered by decending abs(score))
if (Naxes>0) {
  print("Saving individual outliers (abs(score)>0.1) on each plotted histogram...")
  outliers = NULL
  thresh=0.1
  noutliers=0
  for (i in 1:Naxes) {
    out = abs(eigvec[,i])>thresh
    noutliers=noutliers+sum(out)
    if (sum(out)>0)
      outliers = rbind( outliers, cbind( rep(i,sum(out)), rownames(eigvec)[out], eigvec[out,i], abs(eigvec[out,i])) ) 
  }
  if (noutliers>1) {
    write.table(outliers[order(as.numeric(outliers[,1]),(-1)*as.numeric(outliers[,4])),], file=paste(stem,"_INDoutliers.txt",sep=""), quote=FALSE, col.names=c("PC","SubjectID","score","ABSscore"), row.names=FALSE, sep="\t")
  }
  if (noutliers==1) {
    write.table(outliers, file=paste(stem,"_INDoutliers.txt",sep=""), quote=FALSE, col.names=c("PC","SubjectID","score","ABSscore"), row.names=FALSE, sep="\t")
  }
}

#Plot PC1 vs PC2, using classes in final column of "evec" as colours
if (Naxes>0) {
  print("Creating PC1 vs PC2 score plot...")
  pcafile = paste(stem,".evec",sep="")
  FIDpca = file(pcafile,"r")
  lambda = strsplit(readLines(FIDpca,n=1),split=" +")[[1]] [c(-1,-2)]  #Note " +" means match any number of spaces
  NNaxes = length(lambda)
  indfac = as.factor(read.table(FIDpca,header=FALSE,comment.char="",colClasses=c(rep("NULL",NNaxes+1),"factor"))[,])
  close(FIDpca)
  pdf(paste(stem,"_PC1v2.pdf",sep=""))
  plot(eigvec[,1],eigvec[,2], main=paste("PC1/PC2, black=",levels(indfac)[1],", red=",levels(indfac)[2],sep=""), xlab="PC1", ylab="PC2", col=as.numeric(indfac))
  par(oldpar)
  dev.off()
}

#Calculate the number of SNPs in .bed file, using it's size and known nsamp
genofile = paste(stem,".bed",sep="")
####nsamp = dim(eigvec)[1]    This will not work if the number of SNPs is less than the number of individuals
nsamp = as.numeric(strsplit(system(paste("wc ",stem,".pedind",sep=""),intern=TRUE),split=" +")[[1]][2])
rowsize = ceiling(nsamp/4)         #Because each byte stored info for 4 people
bedsize = file.info(genofile)$size
nSNP = round((bedsize-3)/rowsize)        #take 1st 3 bytes out


#Plot scree plot (1st 100 axes, or min(nsamp,nsnp) if smaller
if (Naxes>0) {
  print("Creating scree plot...")
  lambda = scan(paste(stem,".eval",sep=""))
  npoints = min(100,nsamp,nSNP)
  pdf(paste(stem,"_scree.pdf",sep=""))
  plot((1:npoints),lambda[1:npoints],xlab="PC axis",ylab="Eigenvalue",type="b",pch=20)
  lines(c(0,npoints),c(1,1),lty=3)
  dev.off()
}

#This small function replaces NA's with o's in array M (used in gamma calculation)
na2zero=function(m) {
  m[is.na(m)]=0
  return(m) 
}
#This function eads this block of info from BED file, converts to a matrix of genotypes (0/1/2/-9) (rows=individuals)
readbed = function( FID, nlines, nsamp ) {
  g0 = matrix(ncol=nlines, nrow=nsamp)
	  rowsize = ceiling(nsamp/4)         #Because each byte stored info for 4 people
  for (isnp in 1:nlines) {
    rawSNP = readBin(FID, what="raw", n=rowsize)
    SNPbit = matrix(as.numeric(rawToBits(rawSNP)), ncol=2, byrow=TRUE)[1:nsamp,]
    g0[,isnp] = SNPbit[,1] + SNPbit[,2] - 10*((SNPbit[,1]==1)&(SNPbit[,2]==0))
  }
  return(g0)
}

#Do kmeans analysis on g0 matrix.  We assume that nSNPs is small so g0 can be read in one go
#g0 = (nsamp * nsnp) matrix (i.e. one column for each SNP, one row for each invid)
if (kmeans=="YES") {
  print("Calculating kmeans solutions...")
  FID = file(genofile, "rb")
  bytes3 = readBin(FID, what="raw", n=3)
  g0 <- readbed( FID, nSNP, nsamp )    #"-9" = missing, {0,1,2}=genos
  n0 = colSums(g0>=0)         #Number of non-missing values for each SNP
  g0[g0<0] = NA              #Convert "-9" to NA
  u0 = colSums(g0,na.rm=TRUE)               #sum of geno codes over all indivs (remove missing)
  u=u0/n0                                    #mean geno code
  p=(1+u0)/(2*(1+n0))                        #Bayesian posterior estimate of allele freq
  norm = scale(g0, center=TRUE, scale=sqrt(p*(1-p)) )
  norm[is.na(norm)] = 0                     #Re-set missing data =0 on zero-centered axes
  kres0 = kmeans(norm, centers=2, nstart=10);  kclust0 = kres0$cluster
  #Obtain projection onto axis joining the 2 main centroids (="kmeans0")
  norm0 = norm - matrix(rep(1,nsamp),nrow=nsamp)%*%kres0$centers[1,]     #centre on 1st centroid
  load0 = t(diff(kres0$centers)) /sum(diff(kres0$centers)^2)  #loadings are the difference between the 2 centroids on each axis, scaled by the euclidean distance between them
  rotax0 = norm0 %*% load0              #find indiv scores along line joining 2nd centroid
  #Use rotax0 axis to nominate N/N group="1" (=group with smallest var on rotax0)
  var_c1 = var(rotax0[kclust0==1])
  var_c2 = var(rotax0[kclust0==2])
  if (var_c1>var_c2) {
    kclust0[kclust0==2] = 3;  kclust0[kclust0==1] = 2;  kclust0[kclust0==3] = 1
  }
  Nfreq = sqrt(sum(kclust0==1)/length(kclust0));  IIfreq = (1-Nfreq)^2;  IIcount = ceiling(IIfreq*length(kclust0))
  #Orient rotax axis so that NN individuals are to the LEFT
  if ( mean(rotax0[kclust0==1])>mean(rotax0[kclust0==2]) )   rotax0 = -(rotax0-1)
  #Find indices for right-most IIcount individuals
  IIindex = order(-rotax0)[1:IIcount]
  #Re-do kmeans clustering with inv/inv people removed (="kmeans4")
  kres4 = kmeans(norm[-IIindex,], centers=2, nstart=10)
  norm4 = norm - matrix(rep(1,nsamp),nrow=nsamp)%*%kres4$centers[1,] 
  load4 = t(diff(kres4$centers)) /sum(diff(kres4$centers)^2)
  rotax4 = norm4 %*% load4
  #Orient rotax4 axis so that inv/inv individuals are to the RIGHT
  if ( mean(rotax4[IIindex])<0 ) rotax4 = -(rotax4-1)
  #Re-calculate kclust4 using >1.5 as a guide
  kclust4=kclust0*0; kclust4[-IIindex] = kres4$cluster
  if (mean(rotax4[kclust4==1])>mean(rotax4[kclust4==2])) {  #swap "1" and "2" clusters if necessary
    kclust4[kclust4==2] = 3;  kclust4[kclust4==1] = 2;  kclust4[kclust4==3] = 1
  }
  #Re-do inv/inv membership based on membership of >1.5
  kclust4[(rotax4>1)&(rotax4<=1.5)]=2
  kclust4[rotax4>1.5]=3

  #Save eigvec, kclusters and rotated axis as stem.evec2
  eigvecS = make.unique(rep("PC",numoutevec+1),sep="")[2:(numoutevec+1)]
  write.table( data.frame(rownames(eigvec),eigvec,rotax0,kclust0,rotax4,kclust4), file=paste(stem,".evec2",sep=""), quote=FALSE, sep="\t", row.names=FALSE, col.names=c("SubjectID",eigvecS,"rotax0","kclust0","rotax4","kclust4") )
  #Write color-coded figures as pdf 
  pdf(paste(stem,"_kmeans0.pdf",sep=""))
    x=rotax0
    c=kclust0
    brk = seq(min(x),max(x),length.out=61)
    h1= hist(x[c==1], breaks=brk, plot=FALSE)
    h2= hist(x[c==2], breaks=brk , plot=FALSE)
    h3= hist(x[c==3], breaks=brk, plot=FALSE)
    data <- t(cbind(h1$counts,h2$counts,h3$counts))
    barplot(data, beside=FALSE, col=(2:4), space=0, width=1, xlab="k-means axis", ylab="Individual counts")  
    ticks = pretty(brk); convert = (ticks-min(brk))/(max(brk)-min(brk))*length(h1$counts)
    axis(1, at=convert, labels=ticks)
    #lines((d$x-min(brk))/(max(brk)-min(brk))*length(h1$counts), d$y*length(x)*diff(h1$mids[1:2]), lty=2)
  dev.off()
  pdf(paste(stem,"_kmeans4.pdf",sep=""))
    x=rotax4
    c=kclust4
    brk = seq(floor(min(x)*10)/10, ceiling(max(x)*10)/10, by=0.05)
    h1= hist(x[c==1], breaks=brk, plot=FALSE)
    h2= hist(x[c==2], breaks=brk , plot=FALSE)
    h3= hist(x[c==3], breaks=brk, plot=FALSE)
    data <- t(cbind(h1$counts,h2$counts,h3$counts))
    barplot(data, beside=FALSE, col=(2:4), space=0, width=1, xlab="k-means axis", ylab="Individual counts")  
    ticks = pretty(brk); convert = (ticks-min(brk))/(max(brk)-min(brk))*length(h1$counts)
    axis(1, at=convert, labels=ticks)
    #lines((d$x-min(brk))/(max(brk)-min(brk))*length(h1$counts), d$y*length(x)*diff(h1$mids[1:2]), lty=2)
  dev.off()

  #Save loadings to stem.k2gam, also plot loadings histogram
  write.table( data.frame(load0,load4), file=paste(stem,".gamk2",sep=""), quote=FALSE, sep="\t", row.names=FALSE, col.names=c("load0","load4") )
  pdf(paste(stem,"_SNPhistk2.pdf",sep=""), width=6, height=3)
    oldpar = par(mfrow=c(1,2), oma=c(.5,.5,.5,.5), cex.lab=.2, mex=.2, tck=-0.02)
    hist(load0,75, main="load0")
    hist(load4,75, main="load4")
    par(oldpar)
  dev.off()
}


#Calculate SNP loadings
Naxes = min(NNaxes,numgamma,numoutevec)
if (Naxes>0) {
  print("Calculating SNP loadings...")
  outfile =  paste(stem,".gam",sep="")
  block <- 1000                                      #block size (N. SNPs to read at a time)
  FIDout = file(outfile, "w")
  FID = file(genofile, "rb")
  bytes3 = readBin(FID, what="raw", n=3)
  if (rawToChar(bytes3)!="l\033\001") stop("BED file not a v0.99 SNP-major BED file")
  for (i in 0:(nSNP%/%block)) {
    nlines <- min((i+1)*block,nSNP) - i*block
    gamma = matrix( rep(0,nlines*Naxes), ncol=Naxes )
    graw <- readbed( FID, nlines, nsamp )                                  #"-9" = missing, {0,1,2}=genos
    g0 <- graw/2                                                           #"-4.5" = missing, {0,0.5,1}=genos
    n0 = colSums(g0>=0)                                                     #Number of non-missing values for each SNP
    g0[g0<0] = NA                                                          #Convert "-4.5" to NA
    g0 = scale(g0,center=TRUE,scale=FALSE)                                 #Center on mean (makes a difference for missing data
    if (Naxes>0) {
    for (iPC in 1:Naxes) {
      a = eigvec[,iPC]                                           # a is the ith eigen vector = "ancestry" coefficient for each indiv
      gamma[,iPC] = (t(a)%*%na2zero(g0)) / (t(a^2)%*%(!is.na(g0)))     # gamma is a regression coefficient for each different SNP.  When there is missing data, sum(a^2) is different for each SNP
    }
    }
    write.table( gamma, file=FIDout, row.names=FALSE, col.names=FALSE )    #since "file" is a connection, stays open after call
  }
  close(FID)
  close(FIDout)
}

#Plot Q-Q plots on SNP loadings
#Because this can be a large file if saved directly as pdf, I will first save as ps then convert to pdf
Naxes = min(NNaxes,numgamma,numoutevec,numplot)
if (Naxes>0) {
  print("Creating Q-Q plots...")
  #read in "gamma" file
  gamma = as.matrix(read.table(outfile, header=FALSE, nrows=nSNP, comment.char="", colClasses="numeric"))
  #pdf(paste(stem,"_qq.pdf",sep=""))
  postscript(paste(stem,"_qq.ps",sep=""),width=6,height=6,horizontal=FALSE)
  oldpar = par(mfrow=c(ceiling(Naxes/2),1+(Naxes>1)), oma=c(.5,.5,.5,.5), cex.lab=.2, mex=.2, tck=-0.02)
  for (i in 1:Naxes) {
    plot( qnorm( ((1:dim(gamma)[1])-0.5)/dim(gamma)[1], mean(gamma[,i]), sd(gamma[,i]) ), sort(gamma[,i]), main=paste("PC", as.character(i)), pch="." ); grid()
    lines(c(-6,6), c(-6,6))
  }
  par(oldpar)
  dev.off()
  system(paste("ps2pdf ", stem, "_qq.ps ", stem, "_qq.pdf", sep=""))
  system(paste("rm ", stem, "_qq.ps", sep=""))
}

#Plot histograms of SNP loadings
Naxes = min(NNaxes,numgamma,numoutevec,numplot)
if (Naxes>0) {
  print("Creating SNP loading histograms...")
  pdf(paste(stem,"_SNPhist.pdf",sep=""))
  oldpar = par(mfrow=c(ceiling(Naxes/2),1+(Naxes>1)), oma=c(.5,.5,.5,.5), cex.lab=.2, mex=.2, tck=-0.02)
  for (i in 1:Naxes) {
    hist(gamma[,i],75, main=paste("PC",as.character(i)))
  }
  par(oldpar)
  dev.off()
}

#Save outlier SNPs for plotted Q-Q axes (ordered by decending abs(gamma))
Naxes = min(NNaxes,numgamma,numoutevec,numplot)
if (Naxes>0) {
  print("Saving SNP outliers (abs(gamma)>1) on each plotted Q-Q axis...")
  MAP = read.table(paste(stem,".bim",sep=""), header=FALSE, sep="", skip=0, nrows=nSNP, comment.char="", col.names=c("CHR","SNP","","POS","",""), colClasses=c("numeric","character","NULL","numeric","NULL","NULL"))
  for (PC in 1:Naxes) {
    PCoutlier = (abs(gamma[,PC])>1)
    #Use MAP to identify these
    rownames(gamma) = MAP$SNP; rownames(MAP) = MAP$SNP 
    mapo = MAP[PCoutlier,];  indexG=order(-abs(gamma[PCoutlier,PC]));  indexP=order(mapo$CHR,mapo$POS)
    dist2next = c(pmax(rep(0, sum(PCoutlier)-1), mapo[indexP,]$POS[2:sum(PCoutlier)]-mapo[indexP,]$POS[1:(sum(PCoutlier)-1)]),0)
    if (PC==1) {
      dfO = data.frame(PC=rep(PC,length(indexG)), mapo[indexG,], gamma=gamma[PCoutlier,PC][indexG], ABSgamma=abs(gamma[PCoutlier,PC])[indexG], dist2next=dist2next)
    } else {
      dfO = rbind( dfO, data.frame(PC=rep(PC,length(indexG)), mapo[indexG,], gamma=gamma[PCoutlier,PC][indexG], ABSgamma=abs(gamma[PCoutlier,PC])[indexG], dist2next=dist2next) )
    }
  }
  write.table(dfO, file=paste(stem,"_SNPoutliers.txt",sep=""), col.names=TRUE, row.names=FALSE, sep="\t", quote=FALSE)
}

#Plot SNP loading (PC1) vs POS, if gamplot=YES
if (gamplot=="YES") {
  print("Creating SNP loading vs distance plots...")
  pdf(paste(stem,"_PC1gam.pdf",sep=""))
  plot(MAP$POS, abs(gamma[,1]), type="l",col=1, ylab="PC1 ABS SNP loading", xlab="Genomic Position")
  lines(MAP$POS,1+0*MAP$POS,lty=3)
  dev.off()

  pdf(paste(stem,"_gamVpos.pdf",sep=""))
  oldpar = par(mfrow=c(ceiling(Naxes/2),1+(Naxes>1)), oma=c(.5,.5,.5,.5), cex.lab=.2, mex=.2, tck=-0.02)
  for (i in 1:Naxes) {
    plot(MAP$POS, abs(gamma[,i]), type="l",col=1, main=paste("PC",as.character(i)))
    lines(MAP$POS,1+0*MAP$POS,lty=3)
  }
  par(oldpar)
  dev.off()

  #Plot load0 vs POS, if kmeans=YES
  if (kmeans=="YES") {
    pdf(paste(stem,"_PC1gamk2.pdf",sep=""))
    plot(MAP$POS, abs(load0), type="l",col=1, ylab="k-means (load0) ABS SNP loading", xlab="Genomic Position")
    lines(MAP$POS,1+0*MAP$POS,lty=3)
    dev.off()
  }
}

#Plot haplotype/genotype clusters vs genomic order heatmap, if heatplot=YES
#Because this can be a large file if saved directly as pdf, I will first save as ps then convert to pdf
#Note "graw" comes from "calculate SNP loadings" section
if (heatplot=="YES") {
  print("Creating genotype heatmap...")
  graw[graw<0] = NA                                                          #Convert "-9" to NA
  FAM = read.table(paste(stem,".fam",sep=""), header=FALSE, sep="", skip=0, comment.char="", row.names=1, colClasses=c("character",rep("numeric",5)))
  rownames(graw) = rownames(FAM)
  postscript(paste(stem,"_heat.ps",sep=""),width=6,height=6,horizontal=FALSE)
  heatmap(graw, Colv=NA, distfun=function(x){dist(x,method="manhattan")}, scale="none", col=gray(c(1,0.5,0)), breaks=c(-0.5,0.5,1.5,2.5))
  dev.off()
  system(paste("ps2pdf ", stem, "_heat.ps ", stem, "_heat.pdf", sep=""))
  system(paste("rm ", stem, "_heat.ps", sep=""))
}

#Delete .pedsnp and .pedind files
print("Deleting .pedsnp and .pedind files ...")
system(paste("rm ",stem,".pedsnp",sep=""))
system(paste("rm ",stem,".pedind",sep=""))


print("**************************************")
print("EIGENSOFTplus completed. <Hit RETURN>.")
print("**************************************")

