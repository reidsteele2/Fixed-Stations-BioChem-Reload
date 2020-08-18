# fixing the biolsums
# created by Claudette Landry for the Biochem reboot project 
# July 2019
# Edited by Reid Steele, August 11 2020
# Contains code to write to the shared drive or a local directory

# set the working directory 
wd="C:/Users/steeler/Documents/Reid/BCD Creation/Fixed Station Biochem Reload/convertingtoBCDBCS/fixing biolsums" 
setwd(wd)

# required packages and functions
require(zoo)
require(openxlsx)
require(tools)
require(janitor)
source('format_time_CL.R')

# set the file path for the original Biolsums
fp="../original Biolsums"
files=list.files(fp)

# Load in paths
paths=read.csv("../FS BCD BCS/fixed_station_files_RS.csv", stringsAsFactors=FALSE)

# Fix paths to work with shared drive
paths$path = gsub('//ent.dfo-mpo.ca/ATLShares', 'R:/', paths$path)

# read in and edit the biolsum
for (k in 1:length(files)) {
  BiolSum=file.path(fp,files[k])
  Biol <- read.xlsx(BiolSum,sheet = 'BIOLSUMS_FOR_RELOAD')
  # this checks if the headers are correct or sometimes there are lines of metadata present
  # and the headers are not in the first row of the file. This ensure the correct headers
  if('sdate' %in% names(Biol)==F){
    start <- which(Biol[1]=='sdate')+1
    Biol <- read.xlsx(BiolSum,sheet = 'BIOLSUMS_FOR_RELOAD',startRow = start)
  }
  Biol$sdate<-as.numeric(Biol$sdate)
  Biol$sdate <- excel_numeric_to_date(Biol$sdate)
  
  # removes all rows without bottle id which gets rid of the repeating depth rows
  rem <- which(is.na(Biol$id))
  if(length(rem)>0){
    Biol <- Biol[-rem,]
  }

  # fills out the date, time and vessel columns using the most recent date or time in the column
  Biol$sdate <- na.locf(Biol$sdate)
  if(is.null(Biol$stime)==F){
    Biol$stime <- na.locf(Biol$stime)
     if((class(Biol$stime)=='numeric')==F){
       Biol$stime <- as.numeric(Biol$stime)
     }
     Biol$stime <- format_time(Biol$stime)
   }
  if(is.null(Biol$vessel)==F){ 
    Biol$vessel <- na.locf(Biol$vessel)
  }
  
  Biol$sdate <- format(Biol$sdate,format='%d-%b-%Y')
  print(head(Biol[c(1,2,3,4)]))
  g <- paste0('../corrected biolsums/',substr(files[k],start = 1,stop = nchar(files[k])-5),'_edited.csv')
  
  # Local Write
  # write.csv(Biol,file=g,row.names = F)
  
  # Shared write
  write.csv(Biol,file=paste0(paths$path[k], '/', substr(files[k],start = 1,stop = nchar(files[k])-5), '_edited.csv'),row.names = F)
}

rm(list=ls())


