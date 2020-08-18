# this function reads in different time formats including the decimal number that is sometimes 
# output by Excel and transforms them into the standard format HH:MM

# Created by Claudette Landry for the Biochem reload project
# July 2019


format_time <-function(time) {
  
  # format input times to HH:MM (13:30) by guessing input time format
  
  require(lubridate)
  require(schoolmath)
  require(stringr)
  
  if(all(is.na(time))) {
    outtime=time  # return all NA
    #cat("\n",'\n')
    #print("Format time function: Input times are all NA.")
  } else {
    
    # try different formats to see which one works
    
    d=strptime(time,"%H%M%S") # try time format HHMMSS "133050"
    
    if (all(is.na(d))==F){
      d=str_pad(time,width = 6,side = 'left',pad='0')
      d=strptime(d,"%H%M%S")
    }
    
    if (all(is.na(d))) { 
      d=strptime(time,"%H:%M:%S") # try time format HH:MM:SS  "08:30:50" 
    }
    
    if(all(is.na(d))){
      if(is.decimal(as.numeric(na.omit(time)))){
        time = as.numeric(time)
        d=strptime(format(as.POSIXct((time) * 86400, origin = "1970-01-01", tz = "UTC"), "%H:%M"),'%H:%M')
      }else{
        d=NA
      }
    }
    
    # if none works write a message
    if (all(is.na(d))) { 
      cat("\n","\n")
      print("Unknow time format. Add another time format to format_time function.")
      cat("\n","\n")
    }
    
    # output time should look like: HH:MM
    outtime=format(d,"%H:%M")
  }
  
  return(outtime)  
  
}
