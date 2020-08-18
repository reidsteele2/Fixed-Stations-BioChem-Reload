# Reid Steele July 28 2020
# Switch old descriptors with new updated descriptors for files in other_cruises.csv

# set working directory
wd="C:/Users/steeler/Documents/Reid/BCD Creation/Fixed Station Biochem Reload/convertingtoBCDBCS/FS BCD BCS" 
setwd(wd)

# Load in other cruise names and event numbers
other = read.csv('other_cruises.csv')

# Loop through cruises in other
for(i in 1:nrow(other)){
  
  # Mission name
  mission = other$Fixed.Station[i]
  
  if(!(mission %in% c('BCD2001666', 'BCD2003668'))){
  
    # Path to BCD and BCS files
    load_path = file.path(wd, 'Output_RS', mission)
    
    # Load in BCS
    bcs = read.csv(paste0(load_path, '/', mission, '_BCS_test.csv'))
    
    # Load in BCD
    bcd = read.csv(paste0(load_path, '/', mission, '_BCS_test.csv'))
    
    # Fix descriptors
    bcs$MISSION_DESCRIPTOR = ifelse(bcs$MISSION_NAME == other$Cruise[i], other$Meds.mission.number[i], bcs$MISSION_DESCRIPTOR)
    bcd$MISSION_DESCRIPTOR = ifelse(bcd$MISSION_NAME == other$Cruise[i], other$Meds.mission.number[i], bcd$MISSION_DESCRIPTOR)
    
    # Rewrite BCS
    write.csv(bcs, file = paste0(load_path, '/', mission, '_BCS_test.csv'), row.names = FALSE)
    
    # Rewrite BCD
    write.csv(bcd, file = paste0(load_path, '/', mission, '_BCD_test.csv'), row.names = FALSE)
    
  } # Close if
  
} # Close for
