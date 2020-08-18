# compare primary and secondary ctd sensors

compare_sensors <- function(qat,mission) {
  
  sensors=c("oxy","dens","theta","sal","cond","fluor","temp")
  
  for (i in 1:length(sensors)) {
    
  # find columns for each sensor
    sc=grep(sensors[i],names(qat))
   
  # if there is more than one sensor, then cmpare
    if (length(sc)>1) {
     sc1=grep(paste0(sensors[i],1),names(qat)) # column for the first sensor
     sc2=grep(paste0(sensors[i],2),names(qat)) # column for the second sensor 
     
     par(mfrow=c(2,1), mar=c(4,5,3,2))
     
     nm=names(qat)
     ylabel=paste(nm[sc1],"-",nm[sc2])
     title=paste(mission, sensors[i],"sensors difference")
     plot(qat$id,qat[,sc1]-qat[,sc2],ylab=ylabel,xlab="ID",col="blue", main=title)
     abline(0,0)
     
     plot(qat$pressure,qat[,sc1]-qat[,sc2],ylab=ylabel, xlab="Pressure", col="blue")
     abline(0,0)
     
     # save the plotd
     outpath=file.path(getwd(),mission)
     # define file name (goes in the mission folder)
     fn=file.path(outpath,paste0(mission,"_", sensors[i],"_comparison_qat.png"))
     
     dev.copy(png,fn, width=700,height=600, res=90)
     dev.off()
    } # end of if
    
  } # end of for loop
  
  par(mfrow=c(1,1), mar=c(5.1,4.1,4.1,2.1)) # reset to 1 plot per image
  
  
} # end of function