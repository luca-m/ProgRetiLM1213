#!/usr/bin/env Rscript
#
# Confidence Interval Plotter.
#
# Usage : 
#       ./plot_confidence.R <infile> <outfile> <XCol> <YCol> <minYCol> <maxYCol>
#
# Parameters:
#       - infile          CSV file containing simulation records. 
#       - outfile         Output PDF
#       - XCol       Field or coloumn to use as X value
#       - YCol       Field or coloumn to use as Y value
#       - minYCol       Field or coloumn to use as Y lower bound (as R regex)\n
#       - maxYCol       Field or coloumn to use as Y upper bound (as R regex)\n


loadDataFromCsv<-function(filepath){
  data<-read.csv(filepath, header = TRUE)
  return(data)
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
args<-commandArgs(T)
if (length(args)>=6) {
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
    whereY<-labels(data)[[2]][grep(whereY,labels(data)[[2]])][1]
  }
  whereYMin<-as.numeric(args[5])
  if (is.na(whereYMin)){
    whereYMin<-args[5]
    whereYMin<-labels(data)[[2]][grep(whereYMin,labels(data)[[2]])][1]
  }
  whereYMax<-as.numeric(args[6])
  if (is.na(whereYMax)){
    whereYMax<-args[6]
    whereYMax<-labels(data)[[2]][grep(whereYMax,labels(data)[[2]])][1]
  }

  pdf(ofile)
  printDataWConfidence(data,whereX,whereY,whereYMin,whereYMax,"")
  dev.off()
}else{
  cat("ERR: Mandatory parameters missing!\n")
  cat("Usage :\n    ./plot_confidence.R <infile> <outfile> <targetCol> <minTargetCol> <maxTargetCol>\n")
  cat("Params:\n")
  cat("    <infile>          Input CSV file containing the simulation data\n")
  cat("    <outfile>         Output PDF\n")
  cat("    <XCol>       Field or coloumn to use as Y value\n")
  cat("    <YCol>       Field or coloumn to use as Y value\n")
  cat("    <minYCol>       Field or coloumn to use as Y lower bound (as R regex)\n")
  cat("    <minYCol>       Field or coloumn to use as Y upper bound (as R regex)\n")
}