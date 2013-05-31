#!/usr/bin/env Rscript
#
# Confidence Interval Calculator
#
# Usage : ./confidence_interval.R <infile> <targetCol> <confidence>
#
# Parameters:
#       - infile        CSV file containing simulation records. 
#                       (Simulated with same input configuration)
#       - targetCol     Field or coloumn where to calculate confidence interval
#       - confidence    Percentual of confidence to use in interval calculation (0.0, 1.0)


loadDataFromCsv<-function(filepath){
  data<-read.csv(filepath, header = TRUE)
  return(data)
}
calcConfidenceInterval<-function(data, wherelist=c('ID'), confidence=0.95){
  confintervals<-c()
  for (where in wherelist){ 
    s2<-var(data[where])
    mx<-colMeans(data[where])
    n<-dim(data[where])[1]
    a<-qt(confidence, df=n-1)*sqrt(s2/n)
    confintervals<-c(confintervals, mx-a, mx+a)
  }
  return(confintervals) 
}
printDataWConfidence<-function(data,X='X',Y='Y',min_Y='min_Y',max_Y='max_Y',title=""){
  abs_max_Y<-round(max(data[max_Y]))
  plot(data[X][,], data[Y][,], ylim=c(0,abs_max_Y), type="p",xlab=X,ylab=Y)
  # make polygon where coordinates start with lower limit and 
  # then upper limit in reverse order
  polygon( c(data[X][,],rev(data[X][,])) , c(data[min_Y][,], rev(data[max_Y][,])),
          col="grey75", border=FALSE)
  lines(data[X][,], data[Y][,], lwd=2)
  #add red lines on borders of polygon
  lines(data[X][,], data[min_Y][,], col="red",lty=2)
  lines(data[X][,], data[max_Y][,], col="red",lty=2)
  title(main=paste(title,X,Y,sep=' '))
  grid(abs_max_Y,abs_max_Y,col="black")
}

###########################
# MAIN 
###########################
args<-commandArgs(T)
if (length(args)>=3) {
  infile<-args[1]
  
  data<-loadDataFromCsv(infile)
  
  where<-as.numeric(args[2])
  if (is.na(where)){
    where<-args[2]
    where<-labels(data)[[2]][grep(where,labels(data)[[2]])]
  }
  conf<-as.double(args[3])
# 
  data<-data[complete.cases(data),]
  d<-sapply(data,mean)
  interval<-calcConfidenceInterval(data=data,wherelist=where,confidence=conf)
  cat(d,interval,sep=',')
  cat('\n')
  }else{
    cat("ERR: Mandatory parameters missing!\n")
    cat("Usage :\n    ./confidence_interval.R <infile> <targetCol> <confidence>\n")
    cat("Params:\n")
    cat("    <infile>          Input CSV file containing the simulation data\n")
    cat("    <targetCol>       Field or coloumn where to calculate confidence interval (as R regex)\n")
    cat("    <confidence>      Percentual of confidence to use in interval calculation (0.0, 1.0)\n")
  }



