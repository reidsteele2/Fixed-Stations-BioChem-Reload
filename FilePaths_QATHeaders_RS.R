# Reid Steele, August 8 2020
# This code is designed to add headers to Diana's concatenated fixed station qats, update the fixed stations files csv file,
# add new QAT data missions with non-reboot cruise QAT data, and fix mistakes in QAT.
# Edited by Reid Steele, August 11 2020
# Contains code to write to the shared drive or a local directory


# Download files from shared drive

library(dplyr)
library(tidyr)

# set working directory
setwd("C:/Users/steeler/Documents/Reid/BCD Creation/Fixed Station Biochem Reload/convertingtoBCDBCS/FS BCD BCS")

# Load in file list
fp="fixed_station_files.csv"
files=read.csv(fp, stringsAsFactors=FALSE)

# Load in paths
paths=read.csv("fixed_station_files_RS.csv", stringsAsFactors=FALSE)

# Fix paths to work with shared drive
paths$path = gsub('//ent.dfo-mpo.ca/ATLShares', 'R:/', paths$path)

# Remove empty rows
files = dplyr::filter(files, mission != '')

# Fix BiolSums Path
files$Biolpath = 'C:/Users/steeler/Documents/Reid/BCD Creation/Fixed Station Biochem Reload/convertingtoBCDBCS/corrected biolsums'

# Fix QAT Path
files$newqatpath = 'C:/Users/steeler/Documents/Reid/BCD Creation/Fixed Station Biochem Reload/checkingnewqats/NEWQATS_RS'

# Fix ODF Path
files$path_odf = 'C:/Users/steeler/Documents/Reid/BCD Creation/Fixed Station Biochem Reload/convertingtoBCDBCS/ODF files'

# Read in a random QAT file to get headers
headers = colnames(read.csv('C:/Users/steeler/Documents/Reid/BCD Creation/AZMP/QAT/HUD99003_QAT_BC.csv'))

# Archived QAT file list
oldqat = list.files('C:/Users/steeler/Documents/Reid/BCD Creation/Fixed Station Biochem Reload/checkingnewqats/NEWQATS - Archive')

# Arrange files by mission
files = dplyr::arrange(files, mission)

# Load in QAT files to add
qat_add = read.csv('C:/Users/steeler/Documents/Reid/BCD Creation/Fixed Station Biochem Reload/checkingnewqats/QATS_to_add/QAT_filenames.csv')

# Add headers back into new QAT files
for(i in 1:nrow(files)){
  
  # mission
  mission = files$mission[i]
  
  # mission path
  mission_path = paths[paths$mission == mission, 'path']
  
  # load in QAT file
  qat = read.csv(file.path('C:/Users/steeler/Documents/Reid/BCD Creation/Fixed Station Biochem Reload/checkingnewqats/NEWQATS - Archive',oldqat[i]), header = TRUE)
  
  # number of missing columns
  newcols = 29-ncol(qat)
  
  # make null vector for additional rows
  addcols = sample('', nrow(qat), TRUE)
  
  # make null data frame to add additional rows
  for(j in 1:newcols){
    
    # add null rows
    qat = cbind(qat, addcols)
    
  }
  
  # add headers
  colnames(qat) = headers
  
  # add new rows to concatenate for cruises in QAT_filenames.csv
  if(mission %in% qat_add$Fixed.Station){
    
    # file name to add
    file_add = qat_add[qat_add$Fixed.Station == mission, 'QAT.File']
    
    # columns to add
    add = read.csv(paste0('C:/Users/steeler/Documents/Reid/BCD Creation/Fixed Station Biochem Reload/checkingnewqats/QATS_to_add/', file_add), header = FALSE)
    
    # add ctd file
    add_filename = gsub('.QAT', '', file_add)
    add = cbind(add_filename, add)
    
    # number of missing columns
    newcols = 29-ncol(add)
    
    # make null vector for additional rows
    addcols = sample('', nrow(add), TRUE)
    
    # make null data frame to add additional rows
    for(j in 1:newcols){
      
      # add null rows
      add = cbind(add, addcols)
      
    }
    
    # add colnames
    colnames(add) = headers

    # remove spaces
    add$date = gsub('  ', '', add$date)
    add$date = gsub(' A', 'A', add$date)
    add$date = gsub(' J', 'J', add$date)
    add$date = gsub(' F', 'F', add$date)
    add$date = gsub(' M', 'M', add$date)
    add$date = gsub(' S', 'S', add$date)
    add$date = gsub(' O', 'O', add$date)
    add$date = gsub(' N', 'N', add$date)
    add$date = gsub(' D', 'D', add$date)
    add$dens2 = gsub(' NA', '', add$dens2)
    add$oxy2 = gsub(' NA', '', add$oxy2)
    add$theta2 = gsub(' NA', '', add$theta2)
    add$sal2 = gsub(' NA', '', add$sal2)
    add$temp2 = gsub(' NA', '', add$temp2)
    add$cond2 = gsub(' NA', '', add$cond2)
    add$time = gsub(' ', '', add$time)
    
    # add quotes around date and time to match rest of QAT
    add$date = paste0('"', add$date, '"')
    add$time = paste0('"', add$time, '"')
    
    if(mission == 'BCD2003666'){
      add$event = 4.1
      add = add[add$trip <= 10,]
    }
    
    # rbind to qat
    qat = rbind(qat, add)
    
  }
  
  # ======================== #
  # QAT Edits and Typo Fixes #
  # ======================== #
  
  # BCD2000666 has typoed sample IDs in QAT (213000 to 231000)
  if(mission == 'BCD2000666'){
    
    # Subtract 18000 from id to change 231000s to 213000s
    qat$id = ifelse(qat$id > 231000, qat$id - 18000, qat$id)
    
  }
  
  # BCD2006669 has typoed sample IDs in QAT - 241371-241375 should be 241376-241380
  if(mission == 'BCD2006669'){
    
    # add 5 to correct these IDs
    qat$id = ifelse(qat$id %in% 241371:241375, qat$id+5, qat$id)
    
  }
  
  # BCD2008668 has typoed sample IDs in QAT (295000 to 259000)
  if(mission == 'BCD2006668'){
    
    # add 26000 to change 259000s to 295000s
    qat$id = ifelse(qat$id %in% 259251:259260, qat$id+36000, qat$id)
    
  }
  
  # BCD2008669 has typoed sample IDs in QAT - 239791-239795 should be 239796-239800
  if(mission == 'BCD2008669'){
    
    # add 5 to correct these IDs
    qat$id = ifelse(qat$id %in% 239791:239795, qat$id+5, qat$id)
    
  }
  
  # BCD2010669 sample IDs decrease instead of increasing (should be 240821-240825, currently 240821-240817)
  if(mission == 'BCD2010669'){
    
    qat$id = ifelse(qat$event == 2, 240821 + abs(240821 - qat$id), qat$id)
    
  }
  
  # Fix typo in BCD2011666
  if(mission == 'BCD2011666'){
    qat[qat$id == 306740, 'lat'] = 44.2683
  }
  
  # Fix typoed 43s to 44s in BCD2003666 and BCD2009666
  if(mission %in% c('BCD2003666', 'BCD2009666')){
    qat$lat = ifelse(floor(qat$lat == 43), qat$lat+1, qat$lat)
  }
  
  # Fix typo in BCD2012666 QAT longitude
  if(mission == 'BCD2012666'){
    qat[qat$id == 306800, 'lon'] = -63.3183 
  }
  
  # Fix typo in BCD2012666 QAT longitude
  if(mission == 'BCD2000669'){
    qat[qat$event == 5, 'time'] = '"14:13:43"'
    qat[qat$event == 19, 'date'] = '"Nov 14 2000"'
  }
  
  # Fix event number typo in BCD1999668
  if(mission == 'BCD1999668'){
    qat = qat[!(qat$id %in% 205451:205460), ]
  }
  
  # write files
  
  # Write to shared drive
  write.csv(qat, file = paste0(mission_path, '/', mission, '_QAT2020.csv'), na = '', row.names = FALSE)
  
  # Write local copy
  write.csv(qat, file = paste0('C:/Users/steeler/Documents/Reid/BCD Creation/Fixed Station Biochem Reload/checkingnewqats/NEWQATS_RS/', mission, '_QAT2020.csv'), na = '', row.names = FALSE)
  
  # progress meter
  print(i)
}

# Fix QAT filenames
files$newqat = list.files('C:/Users/steeler/Documents/Reid/BCD Creation/Fixed Station Biochem Reload/checkingnewqats/NEWQATS_RS')

# Write new file path
write.csv(files, file = 'fixed_station_files_RS.csv', row.names=FALSE, na = '')
