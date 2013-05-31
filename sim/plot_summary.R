#!/usr/bin/env Rscript
#
# Confidence Interval Plotter.
#
# Usage : 
#       ./plot_summary.R <infile> <outfile> <XCol> <colYPattern>
#
# Parameters:
#       - infile            CSV file containing simulation records. 
#       - outfile            Output file.
#       - colX              Field or coloumn to use as X value (as R regex)
#       - colYPattern       Field or coloumn to use as Y values (as R regex)

loadDataFromCsv<-function(filepath){
  data<-read.csv(filepath, header = TRUE)
  return(data)
}
plotSummary<-function(data, X, ylist=c('ID'),title=''){
  abs_max_Y<- -1
  for (y in ylist){
    abs_max_Y<-max(c(abs_max_Y,round(max(data[y]))))
  }
  plot(data[X][,], data[y][,], ylim=c(0,abs_max_Y), type="l",xlab=X,ylab=paste(ylist,sep=' '))
  i<-0
  ii<-c()
  for (y in ylist){
    i<-i+1
    ii<-c(ii,i)
    lines(data[X][,], data[y][,],lwd=2,col=i)
  }
  legend(0,abs_max_Y,ylist,col=ii,lwd=3)
  title(main=paste(title,X,ylist ))
}
###########################
# MAIN 
###########################
args<-commandArgs(T)
if (length(args)>=3) {
  infile<-args[1]
  ofile<-args[2]
  data<-loadDataFromCsv(infile)
  whereX<-as.numeric(args[3])
  if (is.na(whereX)){
    whereX<-args[3]
    whereX<-labels(data)[[2]][grep(whereX,labels(data)[[2]])][1]
  }
  whereY<-as.numeric(args[4])
  if (is.na(whereY)){
    whereY<-args[4]
    whereY<-labels(data)[[2]][grep(whereY,labels(data)[[2]])]
  } 
  data<-data[complete.cases(data),]
  pdf(ofile)
  plotSummary(data,whereX,whereY)
  dev.off()
  
}else{
  cat("ERR: Mandatory parameters missing!\n")
  cat("Usage :\n    ./plot_summary.R <infile> <colX> <colYPattern>\n")
  cat("Params:\n")
  cat("    <infile>          Input CSV file containing the simulation data\n")
  cat("    <outfile>         Output file\n")
  cat("    <colX>            Field or coloumn to use as X value (as R regex)\n")
  cat("    <colYPattern>     Field or coloumn to use as Y values (as R regex)\n")
}