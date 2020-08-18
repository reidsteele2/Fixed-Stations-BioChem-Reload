# Function returns the indices of the columns in the data frame that have all NA elements
# Written by Claudette Landry, BioChem Reboot project, 2019

na.columns <- function(df) {
  
  # find rows with all NA or empty strings, f is logical
  f <- apply(is.na(df) | df == "", 2, all) 
  
  # indices of the rows with all na
  ind=which(f)
  
  return(ind)
  
}