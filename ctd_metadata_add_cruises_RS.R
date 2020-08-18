# Reid Steele, July 13 2020
# Code designed to update fixed station CTD Metadata files with extra information from CTD casts done on non-reboot cruises
# ODF files, fixed station mission numbers, and cruise numbers are kept in ODF_filenames.csv

require(xlsx)


setwd('C:/Users/steeler/Documents/Reid/BCD Creation/Fixed Station Biochem Reload/convertingtoBCDBCS')

# Load in filenames
filenames = read.csv('./ODF_to_add/ODF_filenames.csv')

# Load in paths
paths=read.csv("./FS BCD BCS/fixed_station_files_RS.csv", stringsAsFactors=FALSE)

# Fix paths to work with shared drive
paths$path = gsub('//ent.dfo-mpo.ca/ATLShares', 'R:/', paths$path)

# loop through filenames
for(i in 1:nrow(filenames)){

  mission = filenames$Fixed.Station[i]
  
  mission_path = paths[paths$mission == mission, 'path']
  
  # Load in ODF file and ctd metadata file - if unique fixed station ID load original file, if not load modified file
  odf = read.delim(paste0('./ODF_to_add/', filenames$ODF.File[i]))
  
  if(i == 1){
    
    ctd_metadata = read.xlsx(paste0('./ODF archive/', mission, '_ctd_metadata.xlsx'), sheetName = 'ODF_INFO')
    
  } else {
    
    if(mission != filenames$Fixed.Station[i-1]){
      
      ctd_metadata = read.xlsx(paste0('./ODF archive/', mission, '_ctd_metadata.xlsx'), sheetName = 'ODF_INFO')
      
      } else {
        
      ctd_metadata = read.xlsx(paste0('./ODF files/', mission, '_ctd_metadata.xlsx'), sheetName = 'ODF_INFO')   
      
      } # close second else
    
  } # close first else
  
  # This ODF file has 2 event rows which messes up the column order, remove first even comment row
  if(filenames$Cruise[i] == 'HUD2002054'){
    odf = odf[-30,]
    odf = as.data.frame(odf)
  }
  
  # This ODF file has 3 event rows which messes up the column order, remove first even comment row and concatenate other 2
  if(filenames$Cruise[i] == 'TEL2004534'){
    com = paste(odf[31,], odf[32,])
    odf[30,] = com
    odf = odf[-31:-32,]
    odf = as.data.frame(odf)
    rm(com)
  }
  
  # Shrink ODF to necessary rows - remove everything after the instrument header, then remove headers and end lat/lon
  odf = odf[1:35,]
  odf = odf[grepl('HEADER', odf) == FALSE]
  odf = odf[grepl('END_L', odf) == FALSE]
  
  # add file name
  odf = c(filenames$ODF.File[i], odf)
  
  # make odf a data frame and add colnames from ctd_metadata
  odf = as.data.frame(odf); odf = t(odf)
  colnames(odf) = colnames(ctd_metadata)
  
  # remove extra writing - 's, ,s, and everything before and including '=', replace Sept with sep
  odf = gsub("'",'', odf)
  odf = gsub(".*= ",'', odf)
  odf = gsub(".*=",'', odf)
  odf = gsub(",",'', odf)
  odf = gsub("Sept",'Sep', odf)
  odf = as.data.frame(odf)
  
  # fix dates
  odf$End_Date_Time = strptime(odf$End_Date_Time, format = '%d-%b-%Y %H:%M:%S', tz = 'GMT')
  odf$Start_Date_Time = strptime(odf$Start_Date_Time, format = '%d-%b-%Y %H:%M:%S', tz = 'GMT')
  odf$Start_Date = strptime(odf$Start_Date, format = '%d-%b-%Y %H:%M:%S', tz = 'GMT')
  odf$End_Date = strptime(odf$End_Date, format = '%d-%b-%Y %H:%M:%S', tz = 'GMT')
  odf$Creation_Date = strptime(odf$Creation_Date, format = '%d-%b-%Y %H:%M:%S', tz = 'GMT')
  odf$Orig_Creation_Date = strptime(odf$Orig_Creation_Date, format = '%d-%b-%Y %H:%M:%S', tz = 'GMT')
  
  # fix errors in BCD2003666
  if(filenames$Cruise[i] == 'MAT2003014'){
    odf$Initial_Latitude = 44.2667
    odf$Event_Number = 1.1
  }
  
  # fix errors in BCD2003666
  if(filenames$Cruise[i] == 'HUD2003067'){
    odf$Event_Number = 4.1
  }
  
  # add an event number to BCD2006666
  if(mission == 'BCD2006666'){
    odf$Event_Number = 1.1
  }
  
  # Rbind ctd metadata and odf
  concat = rbind(ctd_metadata, odf)
  
  # Set numeric fields
  concat$Country_Institute_Code = as.numeric(concat$Country_Institute_Code)
  concat$Cruise_Number = as.numeric(concat$Cruise_Number)
  concat$Event_Number = as.numeric(concat$Event_Number)
  concat$Event_Qualifier1 = as.numeric(concat$Event_Qualifier1)
  concat$Initial_Latitude = as.numeric(concat$Initial_Latitude)
  concat$Initial_Longitude = as.numeric(concat$Initial_Longitude)
  concat$Min_Depth = as.numeric(concat$Min_Depth)
  concat$Max_Depth = as.numeric(concat$Max_Depth)
  concat$Sampling_Interval = as.numeric(concat$Sampling_Interval)
  concat$Sounding = as.numeric(concat$Sounding)
  concat$Depth_Off_Bottom = as.numeric(concat$Depth_Off_Bottom)
  
  # Write
  write.xlsx(concat, file = paste0(mission_path, '/', mission, '_ctd_metadata.xlsx'), sheetName = 'ODF_INFO', row.names = FALSE)

} # Close for loop
