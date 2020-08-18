# checks ranges of qat data
# for now only temp, sal, and oxy but ranges for other parameters can be added

check_qat_ranges <- function(qat) {
  
  
  # check ranges of the sensors
  sen=c("temp","sal","oxy")
  ranges=list(temp=c(-2.5,35),sal=c(0,50),oxy=c(0,11))
  
  for (i in 1:length(sen)){
    # find clumns for sensors sensors
    sid=setdiff(grep(sen[i],names(qat)),grep("_",names(qat)))
    
    # find apropriate range
    r=ranges[[grep(sen[i],names(ranges))]]
    
    # number of records out of range
    oor=length(which(qat[,sid]<r[1] | qat[,sid]>r[2]))
    
    if (oor>0) {
      cat("\n","\n")
      cat(paste(sen[i],"sensors have", oor,"records out of range",r))
    } 
    
    if (oor==0) {
      cat("\n","\n")
      cat(paste("-> Range check: all",sen[i],"within acceptable range",paste(r,collapse=" to ")))
    }
    
  }
  
  
}
  
  