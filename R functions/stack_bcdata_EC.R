# stack wide data table using melt and look up BioChem data sequence for each datatype
# Gordana Lazin may 12, 2016

stack_bcdata_EC <- function(df) {
  require(reshape)
  require(gWidgets2tcltk)
  #source("D:/BioChem QC/Biochem_Functions_R/get_dataseq.r") # function taht extract data sequence from BioChem
  
  # stack data using melt function
  dfs=as.data.frame(melt(df,"id", na.rm=FALSE)) # stacked data frame
  
  # what are the datatypes
  datatypes=as.character(unique(dfs$variable))
  
  # extract data type sequences from biochem table
  #bctypes=get_dataseq(datatypes)
  #get data type seq from spreadsheet
  
  bctypes <- read.xlsx('datatypeseq.xlsx', stringsAsFactors = F, sheetIndex = 1)
  
  # datatypes that are not found in biochem
  metdif=setdiff(datatypes,bctypes$METHOD)
  
  if (length(metdif)>0) {
    ind=which(dfs$variable %in% metdif) # indices of columns
    cat(paste("Data types are not found in BioChem:",paste(metdif,collapse=", ")))
    cat("\n","\n")
    op=gconfirm("Would you like to remove those datatypes from the dataset: ")
    if (op==T) {
      dfs=dfs[-ind,]
      cat("-> Methods removed from the dataset.")
    }
    
    if (op==F) {
      cat("-> Please edit original data column names so they match BioChem Method") 
      stop()
    }
    
  }
  
  # now add column for data sequence: merge stacked data with bctypes
  # mbs is merged data frame
  mdf=merge(dfs,bctypes,by.x="variable", by.y="METHOD")
  
  
  return(mdf)
  
}