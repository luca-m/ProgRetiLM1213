#!/usr/bin/env Rscript
#
# Confidence Interval Plotter.
# Note: it pick the first coloumn as X values
#
# Usage : 
#       ./plot_confidence.R <infile> <outfile> <targetCol> <minTargetCol> <maxTargetCol>
#
# Parameters:
#       - infile          CSV file containing simulation records. 
#       - outfile         Output PDF
#       - targetCol       Field or coloumn to use as Y value
#       - minTargetCol       Field or coloumn to use as Y lower bound (as R regex)\n
#       - maxTargetCol       Field or coloumn to use as Y upper bound (as R regex)\n


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
if (length(args)>=5) {
  infile<-args[1]
  ofile<-args[2]
  
  data<-loadDataFromCsv(infile)
  
  where<-as.numeric(args[3])
  if (is.na(where)){
    where<-args[3]
    where<-labels(data)[[2]][grep(where,labels(data)[[2]])][1]
  }
  whereMin<-as.numeric(args[4])
  if (is.na(whereMin)){
    whereMin<-args[4]
    whereMin<-labels(data)[[2]][grep(whereMin,labels(data)[[2]])][1]
  }
  whereMax<-as.numeric(args[5])
  if (is.na(whereMax)){
    whereMax<-args[5]
    whereMax<-labels(data)[[2]][grep(whereMax,labels(data)[[2]])][1]
  }

  pdf(ofile)
  printDataWConfidence(data,labels(data)[[2]][1],where,whereMin,whereMax)
  dev.off()
}else{
  cat("ERR: Mandatory parameters missing!\n")
  cat("Usage :\n    ./plot_confidence.R <infile> <outfile> <targetCol> <minTargetCol> <maxTargetCol>\n")
  cat("Params:\n")
  cat("    <infile>          Input CSV file containing the simulation data\n")
  cat("    <outfile>         Output PDF\n")
  cat("    <targetCol>       Field or coloumn to use as Y value (as R regex)\n")
  cat("    <minTargetCol>       Field or coloumn to use as Y lower bound (as R regex)\n")
  cat("    <minTargetCol>       Field or coloumn to use as Y upper bound (as R regex)\n")
}