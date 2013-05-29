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
calcConfidenceInterval<-function(data, where='ID', confidence=0.95){
  s2<-var(data[where])
  mx<-colMeans(data[where])
  n<-dim(data[where])[1]
  a<-qt(confidence, df=n-1)*sqrt(s2/n)
  return(c( mx-a, mx+a))
}
printDataWConfidence<-function(data,interval){
  
}

###########################
# MAIN 
###########################
args<-commandArgs(T)
if (length(args)>=3) {
  infile<-args[1]
  where<-as.numeric(args[2])
  if (is.na(where)){
    where<-args[2]
  }
  conf<-as.double(args[3])
  data<-loadDataFromCsv(infile)
  d<-sapply(data,mean)
  interval<-calcConfidenceInterval(data,where,conf)
  cat(d,interval,sep=',')
  cat('\n')
  }else{
    cat("ERR: Mandatory parameters missing!\n")
    cat("Usage :\n    ./confidence_interval.R <infile> <targetCol> <confidence>\n")
    cat("Params:\n")
    cat("    <infile>          Input CSV file containing the simulation data\n")
    cat("    <targetCol>       Field or coloumn where to calculate confidence interval\n")
    cat("    <confidence>      Percentual of confidence to use in interval calculation (0.0, 1.0)\n")
  }
