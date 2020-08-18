# Prepare discrete bottle data for loading to BioChem:
# merge discrete bottle data from $ files: BiolSum, CTD QAT file and ODF headers data
# create BCS header file with metadata file
# Edited by Reid Steele, August 2020
# Contains code to write to the shared drive or a local directory

# Method: 
# load and check all 3 files for inconsistencies (QAT file, BiolSum and CTD metadata)
# convert all the dates to R date-time format
# merge the files based on sample ID and event number
# Create start and end dates and time columns using info from QAT files and CTD metadata
# create start and end lon and lat using info from QAT file
# pick the columns for header file and create header file
# pick the columns for data file and create data file


# RS Issue Log (updated version on shared drive in Fixed Stations BCS Issues Log.docx):
# BCD1999666 - QAT sample IDs are not in BiolSums - 201211-201220
# BCD1999668 - BiolSums sample IDs are not in QAT - 219399-219408, 205431-205440
# BCD1999669 - BiolSums sample IDs are not in QAT - 213224-213228, 213243-213247, 213262-213266, 213127-213131
# BCD2000666 - QAT sample IDs are not in BiolSums - 231321-231340. BiolSums sample IDs are not in QAT - 213321-213340 (Typo, Resolved), 213361-213370, 213391-213399
# BCD2000668 - 10 BiolSums sample IDs are not in QAT - IDs 210981-210990
# BCD2000669 - Discrepancies in BiolSum vd QAT time and depth, BCS created
# BCD2001666 - Record without bottle data assigned CTD gear sequence 90000065. 10 BiolSum sample IDs are not in QAT - IDs 188524-188523
# BCD2001668 - 43 5 digit sample IDs, BCS created
# BCD2001669 - 1 ID is named CTD only, missiong columns.3 records without bottle data assigned CTD gear sequence 90000065. 17 IDs in BiolSums but not QAT.
# BCD2002666 - QAT sample IDs 234851-234900 are not in BiolSums
# BCD2002668 - BiolSums sample IDs 174251-174260 and 256393-256402 are not in QAT
# BCD2002669 - 10 records without bottle data assigned CTD gear sequence 90000065.IDs 234657-234661 and 234665-234669 are in QAT but not BiolSums. IDs 234568-234572 are in BiolSums but not QAT.
# BCD2003666 - BiolSums IDs 261101-261110 are not in QAT
# BCD2003668 - BiolSums IDs are not in QAT: 302027-302032, 263390-263399
# BCD2003669 - 3 records without bottle data assigned CTD gear sequence 90000065 (CTD Only IDs), CTD Only IDs fail cross-check (not in QAT)
# BCD2004666 - A couple of test IDs. Removed and created BCS. No other issues.
# BCD2004668 - IDs in BiolSums missing from QAT - 271946-271955
# BCD2004669 - IDs in QAT missing from BiolSums - 241311-241315
# BCD2005666 - 1 depth cross-check issue between BiolSums and QAT. BCS created.
# BCD2005668 - IDs in BiolSums missing from QAT - 287415-287424, 260751-260760
# BCD2005669 - Mission end date off by a year. 2 BiolSums vs QAT depth outliers.
# BCD2006666 - IDs in BiolSums missing from QAT - 261071-261081
# BCD2006668 - IDs in BiolSums missing from QAT - 259251-259620.  IDs in QAT missing from BiolSums - 295251-295260, 304156-304165
# BCD2006669 - IDs in BiolSums missing from QAT - 241276-241380.  IDs in QAT missing from BiolSums - 241371-241375
# BCD2007666 - IDs in BiolSums missing from QAT - 306531-306540.  IDs in QAT missing from BiolSums - 310454-310465
# BCD2007668 - IDs in BiolSums missing from QAT - 307546-307555.
# BCD2007669 - 3 depth cross-check issues between BiolSums and QAT. BCS created.
# BCD2008666 - IDs in BiolSums missing from QAT - 321001-321010.
# BCD2008668 - IDs in BiolSums missing from QAT - 321877-321886.
# BCD2008669 - IDs in BiolSums missing from QAT - 239796-239800, 242831-242835.  IDs in QAT missing from BiolSums - 239831-239835, 239791-239795
# BCD2009666 - IDs in BiolSums missing from QAT - 306601-306620, 306661-306670
# BCD2009668 - No issues, BCS created.
# BCD2009669 - 3 depth check outliers b/w BiolSums and QAT. Depth check came up as BCD2000669 - Potential bug? Title error or was 2000669 plotted?
# BCD2010666 - IDs in BiolSums missing from QAT - 306711-306720.
# BCD2010669 - IDs in BiolSums missing from QAT - 240822-240825.
# BCD2011666 - 10 start time discrepancies, all by 1 day. 1 latitude discrepancy, typo b/w 44 and 43. BCS created
# BCD2011669 - IDs in BiolSums missing from QAT - 22169. Seems like a typo, IDs should have 6 digits
# BCD2012666 - 1 depth discrepancy, 1 longitude discrepancy (likely typo), 275 day difference in mission end date. BCS created.
# BCD2012669 - 2 depth discrepancies. 33 5 digit sample IDs. 275 day difference in mission end date. BCS created.
# BCD2013666 - 1 depth discrepancy. BCS created.
# BCD2013669 - IDs in BiolSums missing from QAT - 370571-370575.

# set working directory
wd="C:/Users/steeler/Documents/Reid/BCD Creation/Fixed Station Biochem Reload/convertingtoBCDBCS/FS BCD BCS" 
setwd(wd)

# load required packages and source functions
require(dplyr)
require(xlsx)
require(lubridate)
require(marmap)
require(htmlwidgets)
require(gWidgets2tcltk)
source("format_time.r")
source("format_date.r")
source("gebco_depth_range_CL_RS.r")
source("na.rows.r")
source("bctime.r")
source("clean_xls.r")
source("check_biolsum1_CL.r")
source("check_qat1.r")
source("check_ctd_metadata_CL.r")
source("mkdirs.r")

# Current Issues - Aug 11, 2020

# Unsure if some data is in IML for BC2004666 and BCD2000666, waiting for email from IML
# There is salinity data in BioChem but not in BiolSums for the following cruises
# I was unable to find salinity data on the shared drive for these cruises, but it may still be somewhere:
# BCD1999669, BCD2000666, BCD2000668, BCD200669, BCD2009669

# BCDs with issues - 7/41


# ====================#
# DEFINE FILES TO LOAD
# ====================#

# Read in list of cruise info
cruise_list = read.xlsx('C:/Users/steeler/Documents/Reid/Cruise_list_reboot_updated_JB.xlsx', 2)[,1:3]

# this file "fixed_station_files.csv" contains list of files to be loaded
# the file should be placed in the data by year and cruise folder in Src
fp="fixed_station_files_RS.csv"
files_all=read.csv(fp, stringsAsFactors=FALSE)

# Load in other cruise names and event numbers
other = read.csv('other_cruises.csv')

# Load in cruises with missing CTD data
ctd_miss = read.xlsx('C:/Users/steeler/Documents/Reid/BCD Creation/Fixed Station Biochem Reload/FS_Missing_QAT_Data.xlsx', 1)

# enter mission and protocol
mission="BCD1999668"  #this has to be changed manually for each mission
protocol="AZMP"

# Get year
yr = substr(mission, 4, 7)

# Filter cruise info to current mission
cruise_info = dplyr::filter(cruise_list, Regional.Mission.ID == mission)

# select files for this particular mission
files=files_all[files_all$mission==mission,]

# Fix paths to work with shared drive
files$path = gsub('//ent.dfo-mpo.ca/ATLShares', 'R:/', paths$path)

BiolSum=file.path(files$Biolpath,files$Biolsumedit)
qatFile=file.path(files$newqatpath,files$newqat)
odfFile=file.path(files$path_odf,files$odf)

# create a directory in the current folder with the cruise name
outpath=file.path(wd,'Output_RS',mission)
dir.create(outpath, showWarnings = FALSE)


# because some of the dates in Biolsums are accounted for in other cruises this file containing the accounted for cruise dates 
# needs to be read in so that the dates can be removed from the biolsums while processing
acfs<-"C:/Users/steeler/Documents/Reid/BCD Creation/Fixed Station Biochem Reload/Accounting for ODF/accounted for dates and cruises.csv"
accounted<-read.csv(acfs)
accounted=accounted[accounted$BCD_cruise==mission,]
accounted$Biolsum_date=format_date(accounted$Biolsum_date)

# =================== #
# DEFINE REPORT FILE
# =================== #

n=now() # make time stamp to mark the start of processing
timestamp=paste0(year(n), sprintf("%02d",month(n)),sprintf("%02d",day(n)),
                 sprintf("%02d",hour(n)),sprintf("%02d",minute(n)),sprintf("%02d",floor(second(n))))

# name of the report file                 
report_file=paste0(mission,"_BCS_report_",timestamp, ".txt")
report_file=file.path(outpath,report_file)

# write input files into report
sink(file=report_file,append=TRUE, split=TRUE)
cat("\n")
cat(paste(mission,"metadata QC log, ", n))
cat("\n")
cat(c("-------","\n","\n"))

cat("Input file:", BiolSum)
cat("\n")
cat("Input file:", qatFile)
cat("\n")
cat("Input file:", odfFile)
sink()

# define an issue counter
issues=0

# =============#
# Check BiolSum 
# =============#

# BiolSum is file name, and check_biolsum1 is a function for QC
bsum_flagged=check_biolsum1(BiolSum)

# biolsum with regular sample IDs
bsum_header=bsum_flagged[which(bsum_flagged$flag != 2),]

# lines with duplicate regular sample IDs
bsum_issues=which(bsum_header$flag_bs==99)

# dataframe with test events
bsum_tests=bsum_flagged[which(bsum_flagged$flag == 2),]

# compare and remove dates accounted for in other cruises like AZMP and Groundfish
bsum_header=bsum_header[which(!bsum_header$sdate_bs %in% accounted$Biolsum_date),]

# ===================================#
# read ODF header file (CTD Metadata) 
# ===================================#

# function returns a list
odf_list=check_ctd_metadata(odfFile)

odf_info=odf_list$odf_info #one line data frame with all mission information from odf header. 
odf_header=odf_list$odf_header #dataframe containing CTD metadata that will be used in the header

odf_full = read.xlsx(odfFile, 1)

# ==============#
# read QAT file 
# ==============#

# flagged qat file: 2 is test casts, 99 is duplicates, 0 is ok
qat_flagged=check_qat1(qatFile)

# dataframe with test data
qat_tests=qat_flagged[which(qat_flagged$flag ==2),]

# dataframe with regular data
qat_header=qat_flagged[which(qat_flagged$flag != 2),]

# issues in regular data (duplicates of regular samples)
qat_issues=which(qat_header$flag_qat==99)

# ============#
# track issues
# ============#

no_issues=length(c(bsum_issues,qat_issues)) #blog_issues removed for Fixed stations

# flag for the issues in the individula files
issue_files=0
# if there are issues in individual files set issue_files to 1
if(no_issues>0){
  issue_files=1
}


# Remove CTD Only Rows

if(nrow(bsum_header[bsum_header$id_bs %in% c('CTD ONLY', 'CTD', 'CTD ', 'ONLY', 'Only', 'Only!', 'CTD only'),]) > 0){
 
  # Write to report
  sink(file=report_file,append=TRUE, split=TRUE)
  cat("\n","\n")
  cat(paste(nrow(bsum_header[bsum_header$id_bs == 'CTD ONLY',])),"CTD Only ID(s) removed")
  sink()
   
  # Remove CTD only rows (many variations)
  bsum_header = bsum_header[!(bsum_header$id_bs %in% c('CTD ONLY', 'CTD', 'CTD ', 'ONLY', 'Only', 'Only!', 'CTD only')),]
  
} # close if statement

# set ids to numeric
bsum_header$id_bs = as.numeric(bsum_header$id_bs)

# =================================================================================================#
# compare QAT and BiolSum Sample ID before merging: ordinary sample ID with bottle data
# =================================================================================================#

# check if there are any SAMPLE ID qat that are not in bsum
id_not_in_bsum=setdiff(unique(qat_header$id_qat),unique(bsum_header$id_bs))
id_not_in_qat=setdiff(unique(bsum_header$id_bs),unique(qat_header$id_qat))

# if there are events missing print the message on the screen
sink(file=report_file,append=TRUE, split=TRUE)
if(length(id_not_in_bsum)>0) {
  issues=issues+1
  cat("\n","\n")
  cat(paste("-> Cross Check: Issue",issues, "-","Sample ID found in QAT file but not in BiolSums."))
  cat("\n")
  cat("These IDs will be deleted from BCS - please confirm no bottle data exists for these IDs before proceeding:")
  cat("\n","\n")
  print(qat_header[which(qat_header$id_qat %in% id_not_in_bsum),c(5,1:4,6:9)],row.names = FALSE)
} else {
  cat("\n","\n")
  cat("-> Cross Check: All Sample IDs from QAT are found in BiolSums.") }


if(length(id_not_in_qat)>0) {
  issues=issues+1
  cat("\n","\n")
  cat(paste("-> Cross Check: Issue",issues, "- Sample ID found in BiolSum but not in QAT:"))
  cat("\n","\n")
  print(bsum_header[which(bsum_header$id_bs %in% id_not_in_qat),c(8,1:7,9)],row.names = FALSE)
} else {
  cat("\n","\n")
  cat("-> Cross Check: All Sample IDs from BiolSum are found in QAT.") 
  
}
sink()

# ============================================================ #
# Add null rows for missing QAT data and remove extra QAT data #
# ============================================================ #

if(length(id_not_in_qat) > 0 ){
  
  # create null rows to add to QAT
  qat_names = colnames(qat_header)
  null_row = sample(NA, length(qat_names), TRUE)
  qat_nulls = NULL
  
  # concatenate null rows and assign sample IDs
  for(i in 1:length(id_not_in_qat)){
  
    qat_nulls = rbind(qat_nulls, null_row)
    colnames(qat_nulls) = qat_names
    rownames(qat_nulls) = NULL
    
    # Put in sample ID
    qat_nulls[i, 'id_qat'] = id_not_in_qat[i]
    
    # Put in mission
    qat_nulls[i, 'cruise_qat'] = mission
    
    # Pull biolsums date and time as a substitute
    qat_nulls[i, 'date_time_qat'] = as.character(bsum_header[bsum_header$id_bs == id_not_in_qat[i], 'date_time_bs'])
    qat_nulls[i, 'last_bottle_datetime_qat'] = as.character(bsum_header[bsum_header$id_bs == id_not_in_qat[i], 'date_time_bs'])
    
    # Use biolsums start date if date_time_bs is blank
    if(is.na(qat_nulls[i, 'date_time_qat']) == TRUE){
      qat_nulls[i, 'date_time_qat'] = as.character(bsum_header[bsum_header$id_bs == id_not_in_qat[i], 'sdate_bs'])
    }
    
    if(is.na(qat_nulls[i, 'last_bottle_datetime_qat']) == TRUE){
      qat_nulls[i, 'last_bottle_datetime_qat'] = as.character(bsum_header[bsum_header$id_bs == id_not_in_qat[i], 'sdate_bs'])
    }
    
    # Hard code latitude by station
    if(grepl(666, mission) == TRUE){
      qat_nulls[i, 'lat_qat'] = 44.2663
      qat_nulls[i, 'lon_qat'] = -63.3167
    }
    if(grepl(668, mission) == TRUE){
      qat_nulls[i, 'lat_qat'] = 47.7838
      qat_nulls[i, 'lon_qat'] = -64.0333
    }
    if(grepl(669, mission) == TRUE){
      qat_nulls[i, 'lat_qat'] = 44.9333
      qat_nulls[i, 'lon_qat'] = -66.85
    }
    
    id_u1 = id_not_in_qat[i] + 1
    id_d1 = id_not_in_qat[i] - 1
    
    if(id_u1 %in% qat_header$id_qat){
      qat_nulls[i, 'event_qat'] = qat_header[qat_header$id_qat == id_u1, 'event_qat'] - 1
    }
    
    if(id_d1 %in% qat_header$id_qat){
      qat_nulls[i, 'event_qat'] = qat_header[qat_header$id_qat == id_d1, 'event_qat'] + 1
    }
    
    if(i != 1){
      if((id_not_in_qat[i]-1 == id_not_in_qat[i-1]) | (id_not_in_qat[i]+1 == id_not_in_qat[i-1])){
        qat_nulls[i, 'event_qat'] = qat_nulls[i-1, 'event_qat']
      }
    }
    
  } # close for loop
  
  # Coerce to data frame
  qat_nulls = as.data.frame(qat_nulls)
  
  # Fix cruise-specific time format issues
  if(is.na(strptime(qat_nulls$date_time_qat, format = '%d-%b-%Y', tz = 'GMT'))[1] == FALSE){
    qat_nulls$date_time_qat = paste(strptime(qat_nulls$date_time_qat, format = '%d-%b-%Y', tz = 'GMT'), '00:00:00')
    qat_nulls$last_bottle_datetime_qat = paste(strptime(qat_nulls$last_bottle_datetime_qat, format = '%d-%b-%Y', tz = 'GMT'), '00:00:00')
  }

  # rbind nulls to qat data, requires reformatting of dates, coerce numerics
  qat_nulls$id_qat = as.numeric(qat_nulls$id_qat)
  qat_add = as.data.frame(qat_header)
  qat_add$date_time_qat = as.character(qat_add$date_time_qat)
  qat_add$last_bottle_datetime_qat = as.character(qat_add$last_bottle_datetime_qat)  
  qat_header = rbind(qat_add, qat_nulls)
  qat_header$date_time_qat = as.POSIXlt(qat_header$date_time_qat, 'GMT')
  qat_header$last_bottle_datetime_qat = as.POSIXlt(qat_header$last_bottle_datetime_qat, 'GMT')
  qat_header$lat_qat = as.numeric(qat_header$lat_qat)
  qat_header$lon_qat = as.numeric(qat_header$lon_qat)
  qat_header$event_qat = as.numeric(qat_header$event_qat)
  qat_header$pressure_qat = as.numeric(qat_header$pressure_qat)
  qat_header$id_qat = as.numeric(qat_header$id_qat)
  qat_header$flag_qat = as.numeric(qat_header$flag_qat)
  
  # Remove Issue
  issues = issues-1
  
  # Write to report
  sink(file=report_file,append=TRUE, split=TRUE)
  cat("\n","\n")
  cat(paste(length(id_not_in_qat),"Null rows added to QAT file to match BiolSums"))
  sink()
  
} # close if statement

# =================================================== #
# Insert event numbers which require individual fixes #
# --------------------------------------------------- #

if(mission == 'BCD1999668'){
  qat_header$event_qat = ifelse(is.na(qat_header$event_qat) == TRUE, 801, qat_header$event_qat)
}

if(mission == 'BCD1999669'){
  qat_header$event_qat = ifelse(qat_header$id_qat %in% 213224:213228, 22, qat_header$event_qat)
  qat_header$event_qat = ifelse(qat_header$id_qat %in% 213243:213247, 20, qat_header$event_qat)
  qat_header$event_qat = ifelse(qat_header$id_qat %in% 213262:213266, 21, qat_header$event_qat)
  qat_header$event_qat = ifelse(qat_header$id_qat %in% 213127:213131, 18, qat_header$event_qat)
}

if(mission == 'BCD2000666'){
  qat_header$event_qat = ifelse(is.na(qat_header$event_qat) == TRUE, 88, qat_header$event_qat)
  qat_header$event_qat = ifelse(qat_header$date_time_qat == as.POSIXlt('2000-10-25 00:00:00', tz = 'GMT'), 343, qat_header$event_qat)
}

if(mission == 'BCD2000668'){
  qat_header[qat_header$id_qat %in% id_not_in_qat, 'event_qat'] = 800
}

if(mission == 'BCD2001666'){
  qat_header$event_qat = ifelse(is.na(qat_header$event_qat) == TRUE, 78, qat_header$event_qat)
}

if(mission == 'BCD2001669'){
  qat_header$event_qat = ifelse(qat_header$id_qat %in% 171182:171186, 8, qat_header$event_qat)
  qat_header$event_qat = ifelse(qat_header$id_qat %in% 234525:234529, 16, qat_header$event_qat)
  qat_header$event_qat = ifelse(qat_header$id_qat %in% 234544:234548, 18, qat_header$event_qat)
  qat_header$event_qat = ifelse(qat_header$id_qat == 234505, 13, qat_header$event_qat)
}

if(mission == 'BCD2002666'){
  qat_header$event_qat = ifelse(qat_header$id_qat %in% 258001:258010, 0, qat_header$event_qat)
  qat_header$event_qat = ifelse(qat_header$id_qat %in% 258461:258470, 125, qat_header$event_qat)
  qat_header$event_qat = ifelse(qat_header$id_qat %in% 258843:258852, 100, qat_header$event_qat)
  qat_header$event_qat = ifelse(qat_header$id_qat %in% 245209:245218, 204, qat_header$event_qat)
  qat_header$event_qat = ifelse(qat_header$id_qat %in% 234881:234890, 268, qat_header$event_qat)
}

if(mission == 'BCD2002668'){
  qat_header$event_qat = ifelse(is.na(qat_header$event_qat) == TRUE, 117, qat_header$event_qat)
}

if(mission == 'BCD2002669'){
  qat_header$event_qat = ifelse(is.na(qat_header$event_qat) == TRUE, 22, qat_header$event_qat)
}

if(mission == 'BCD2003666'){
  qat_header$event_qat = ifelse(is.na(qat_header$event_qat) == TRUE, 1.1, qat_header$event_qat)
}

if(mission == 'BCD2003668'){
  qat_header$event_qat = ifelse(qat_header$id_qat %in% 263390:263399, 66, qat_header$event_qat)
}

if(mission == 'BCD2003669'){
  qat_header$event_qat = ifelse(is.na(qat_header$event_qat) == TRUE, 1, qat_header$event_qat)
}

if(mission %in% c('BCD2004668', 'BCD2005668', 'BCD2007668', 'BCD2008668')){
  qat_header$event_qat = ifelse(is.na(qat_header$event_qat) == TRUE, 668, qat_header$event_qat)
}

if(mission == 'BCD2006666'){
  qat_header$event_qat = ifelse(is.na(qat_header$event_qat) == TRUE, 1.1, qat_header$event_qat)
  # Fix incorrect event assignment
  qat_header[qat_header$id_qat == 261081, 'event_qat'] = 7
}

if(mission == 'BCD2006668'){
  qat_header$event_qat = ifelse(is.na(qat_header$event_qat) == TRUE, 127, qat_header$event_qat)
}

if(mission == 'BCD2006668'){
  qat_header$event_qat = ifelse(is.na(qat_header$event_qat) == TRUE, 127, qat_header$event_qat)
}

if(mission == 'BCD2009666'){
  qat_header$event_qat = ifelse(is.na(qat_header$event_qat) == TRUE, 1, qat_header$event_qat)
}

if(mission == 'BCD2010666'){
  qat_header$event_qat = ifelse(is.na(qat_header$event_qat) == TRUE, 7, qat_header$event_qat)  
}

if(mission == 'BCD2011669'){
  
  qat_header$event_qat = ifelse(qat_header$id_qat == 22169, 11, qat_header$event_qat)
  
}

# ==================== #
# Remove Extra QAT IDs #
# -------------------- #

if(length(id_not_in_bsum) > 0){
  
  # Remove QAT ids missing from biolsums
  qat_header = qat_header[!(qat_header$id_qat %in% id_not_in_bsum),]
  
  # Remove issues
  issues = issues-1
  
  # Write to report
  sink(file=report_file,append=TRUE, split=TRUE)
  cat("\n","\n")
  cat(paste(length(id_not_in_bsum),"QAT-unique IDs removed"))
  sink()
  
} # close if statement

# =================================================================================================#
# compare QAT and BIolSum events and Sample ID before merging: CTD casts without bottle data (tests)
# =================================================================================================#

# how many events are in bsum, qat, blog and odf
n_bsum=length(unique(bsum_tests$event_bs))
n_qat=length(unique(qat_tests$event_qat))

# check if there are EVENTS in qat that are not in bsum
events_not_in_bsum=setdiff(unique(qat_tests$event_qat),unique(bsum_tests$event_bs))
events_not_in_qat=setdiff(unique(bsum_tests$event_bs),unique(qat_tests$event_qat))

# print the message on the screen if there is difference in number of events
sink(file=report_file,append=TRUE, split=TRUE)
if (length(events_not_in_qat)>0 | length(events_not_in_bsum)>0) {
  issues=issues+1
  cat("\n","\n")
  cat(paste("-> Cross Check CTD data only: Issue", issues, "- Events in QAT and BiolSum file are not the same"))
  cat("\n","\n")
  cat(paste("-> Number of CTD only events in QAT file:", n_qat))
  cat("\n","\n")
  cat(paste("-> Number of CTD only events in BiolSum file:", n_bsum))
  cat("\n","\n")
  
  if (length(events_not_in_bsum)>0){
    cat(paste("->", length(events_not_in_bsum), " CTD Events not in BiolSum:"))
    cat("\n","\n")
    print(qat_tests[which(qat_tests$event_qat %in% events_not_in_bsum),],row.names = FALSE)
  }
  
  if (length(events_not_in_qat)>0) {
    cat("\n","\n")
    cat(paste(length(events_not_in_qat)," CTD Events not in QAT file:"))
    cat("\n","\n")
    print(bsum_tests[which(bsum_tests$event_bs %in% events_not_in_qat),1:10],row.names = FALSE)
  }
  
} else { 
  cat("\n","\n")
  cat("-> Cross Check CTD data only: Events in QAT and BiolSum are the same.")}
sink()



# decide to proceed with merging or not

if (issues>0 | issue_files>0) {
  sink(file=report_file,append=TRUE, split=TRUE)
  cat("\n","\n")
  cat("-> Cannot proceed. Please investigate reported issues.")
  sink()
  stop()
} 

sink(file=report_file,append=TRUE, split=TRUE)
cat("\n","\n")
cat("-> No issues detected so far. Continue with file merging...")
sink()

# ==========================================================#
#  MERGING: BiolSums, QAT, and ODF headers for CTD data only
# ==========================================================#

# merge bsum and qat based on Sample ID
bsum_qat_tests=merge(qat_tests,bsum_tests, by.x="id_qat", by.y="id_bs", all=TRUE)

# merge bsum_qat with odf headers based on event
final_tests=merge(bsum_qat_tests,odf_header, by.x="event_qat" ,by.y="Event_Number_odf", all.x=TRUE) #changed to final_tests because no bridge log

# replace NA in BiolSum depth with QAT pressure with 1 decimal place
na_depth=which(is.na(final_tests$depth_bs))
if (length(na_depth)>0) {
  final_tests$depth_bs[na_depth]=round(final_tests$pressure_qat[na_depth],digits=1)
}

# replace 999999 sample ID in BiolSum with ID from QAT
final_tests$id_bs=final_tests$id_qat

final_tests=unique(final_tests)  # remove all repeated rows

# ========================================================#
#  MERGING: BiolSums, QAT, and ODF headers for bottle data
# ========================================================#

# now I have dataframes to merge:
# bsum_header, odf_header, qat_header

# merge bsum and qat based on Sample ID
bsum_qat=merge(bsum_header,qat_header, by.x="id_bs", by.y="id_qat", all=TRUE)

# check if the events match
ce=length(which(abs(bsum_qat$event_bs-bsum_qat$event_qat) >0))

# if there is discrepancies print the message
if (ce>0) {
  sink(file=report_file,append=TRUE, split=TRUE)
  cat("\n","\n")
  cat(paste(ce,"Different Events in QAT and BiolSums for the same Sample ID"))
  cat("\n","\n")
  print(bsum_qat[which(abs(bsum_qat$event_bs-bsum_qat$event_qat) >0),])
  sink()
}

# merge bsum_qat with odf headers based on event
final=merge(bsum_qat,odf_header, by.x="event_qat" ,by.y="Event_Number_odf", all=TRUE) #changed to final because of no bridge log

# done with merging. Merged file is called "final"

# Change event to PAR
if(mission == 'BCD2000666'){
  final$event_qat = ifelse(final$event_qat == 3, 246, final$event_qat)
}

# -----------------------------------------------------------------#
# make start and end time columns: composite of QAT and odf headers
# -----------------------------------------------------------------#

# start and end date_time are from bridge log 
# add start date_time columns, includes exceptions for cruises with QAT/ODF time discrepancies
if(mission != 'BCD2011666'){
  final$event_sdate_stime = as.POSIXlt(ifelse(is.na(final$start_date_time_odf) == FALSE, # start date_time from ODF header
    as.character(final$start_date_time_odf), as.character(final$date_time_qat)), tz = 'GMT')  #unless it is NA (if NA, from QAT)
  final$event_edate_etime = final$last_bottle_datetime_qat
} else {
  final$event_sdate_stime=final$date_time_qat # start date_time from QAT for BCD2011666
  final$event_edate_etime=final$last_bottle_datetime_qat
}

if(mission == 'BCD2000669'){
  final$event_sdate_stime = as.POSIXlt(ifelse(final$event_qat %in% 2:4, as.character(final$date_time_qat), as.character(final$start_date_time_odf)), tz = 'GMT')
}

# ---------------------------- #
# CHECK FOR SUSPECT SAMPLE IDs
# ---------------------------- #

# check if there are sample ID's with less than 6 digits
suspect_id_ind=which(nchar(final$id_bs)!=6 & !is.na(final$id_bs))

sink(file=report_file,append=TRUE, split=TRUE)
if (length(suspect_id_ind)>0){
  cat(c("\n","\n"))
  cat("-> Suspect Sample IDs found:")
  cat(c("\n","\n"))
  print(final[suspect_id_ind,])
  #o=readline("Would you like to remove suspect samples? (y or n):")
  #if (o=="y") { final=final[-suspect_id_ind,] 
  #cat(c("\n","\n"))
  #cat("-> Suspect Sample IDs removed.")
  #}
}
sink()

finalB=final # to keep a copy of final for bottles

# subset final to contain only CTD events  
final_bottles=final[which(!is.na(final$id_bs)),]

# re-order the columns in tests datframe
final_tests=final_tests[,names(final_bottles)]

# stack together test casts and regular bottle casts
final=rbind(final_tests,final_bottles)

#         START QC FOR METADATA           #
# ========================================#
# PLOT THE DATA TO CHECK FOR DISCREPANCIES
# ========================================#

par(mfrow=c(1,1), mar=c(5.1,4.1,4.1,2.1)) # make sure to have 1 plot per image

# Make columns for time and location flags and set them to 1 (correct value)
final$position_qc_code=1
final$time_qc_code=1

#-----------------------------------#
# check LATITUDE in qat file and CTD
#-----------------------------------#

# Fix lat/lon in null QATs (hard-coded) to match ODF
if(mission == 'BCD2006666'){
  final[final$event_qat==100, 'lat_qat'] = final[final$event_qat==100, 'Initial_Latitude_odf']
  final[final$event_qat==100, 'lon_qat'] = final[final$event_qat==100, 'Initial_Longitude_odf']
}

if(mission == 'BCD2006668'){
  final[final$event_qat==127, 'lat_qat'] = final[final$event_qat==127, 'Initial_Latitude_odf']
  final[final$event_qat==127, 'lon_qat'] = final[final$event_qat==127, 'Initial_Longitude_odf']
}

if(mission == 'BCD2007668'){
  final[final$event_qat==668, 'lat_qat'] = final[final$event_qat==668, 'Initial_Latitude_odf']
  final[final$event_qat==668, 'lon_qat'] = final[final$event_qat==668, 'Initial_Longitude_odf']
}

latDif= final$lat_qat-final$Initial_Latitude_odf
ld=which(abs(latDif)>0.03) # flag latitudes that are different by 0.03 deg (about 3km) or more

# ---> DECIDE WHICH FLAG TO ASSIGN FOR POSITION <-----
final$position_qc_code[ld]=2  #assign flag

plot_title=paste("Latitude check: QAT file vs. ODF file","\n",qat_header$cruise_qat[1])

plot(final$event_qat,latDif, xlab="Event Number", ylab="QAT Lat  -  ODF Lat   [deg]", 
     main=plot_title, col="blue")
points(final$event_qat[ld],latDif[ld],pch=19,col="red")
abline(0,0)

# define file name (goes in the mission folder)
fn=file.path(outpath,paste0(mission,"_lat_check_QAT_ODF.png"))

dev.copy(png,fn, width=700,height=600, res=90)
dev.off()


sink(file=report_file,append=TRUE, split=TRUE)
if (length(ld)>0) {
  cat("\n","\n")
  cat("-> Latitude difference between ODF and QAT > 0.03 deg:")
  cat("\n","\n")
  print(final[ld,c("event_qat","start_date_time_odf","date_time_qat","Initial_Latitude_odf","lat_qat","Initial_Longitude_odf","lon_qat")])
}
sink()

# -----------------------------------#
# check LONGITUDE in qat file and CTD
# -----------------------------------#

# Fix typo in BCD2012666 QAT longitude
if(mission == 'BCD2012666'){
  final[final$id_bs == 306800, 'lon_qat'] = final[final$id_bs == 306800, 'Initial_Longitude_odf'] 
}


lonDif=final$lon_qat-final$Initial_Longitude_odf
ld=which(abs(lonDif)>0.03) # flag latitudes that are different by 0.03 deg (about 3km) or more

# ---> DECIDE WHICH FLAG TO ASSIGN FOR POSITION <-----
final$position_qc_code[ld]=2  #assign flag

plot_title=paste("Longitude check: QAT file vs. ODF file","\n",qat_header$cruise_qat[1])

plot(final$event_qat,lonDif, xlab="Event Number", ylab="QAT Lon  -  ODF Lon   [deg]", 
     main=plot_title, col="blue")
points(final$event_qat[ld],lonDif[ld],pch=19,col="red")
abline(0,0)

# define file name (goes in the mission folder)
fn=file.path(outpath,paste0(mission,"_lon_check_QAT_ODF.png"))

dev.copy(png,fn,width=700,height=600, res=90)
dev.off()

sink(file=report_file,append=TRUE, split=TRUE)
if (length(ld)>0) {
  cat("\n","\n")
  cat("-> Longitude difference between ODF and QAT > 0.03 deg:")
  cat("\n","\n")
  print(final[ld, c("event_qat","start_date_time_odf","date_time_qat","Initial_Latitude_odf","lat_qat","Initial_Longitude_odf","lon_qat")])
  
}

sink()

# --------------------------------------------------------------------#
# check TIME (date and time together): QAT vs. ODF event start headers
# --------------------------------------------------------------------#

timeDif1=difftime(final$start_date_time_odf,final$date_time_qat, units="mins")
ld=which(abs(timeDif1)>20) # time difference greater than 20 min

# ---> DECIDE HOW TO ASSIGN FLAGS FOR TIME <-----
final$time_qc_code[ld]=2  #assign flag

plot_title=paste("CTD Date_Time check: ODF start time vs. QAT time","\n",qat_header$cruise_qat[1])

plot(final$event_qat,timeDif1, xlab="Event Number", ylab="ODF start time  -  QAT Time  [minutes]", 
     main=plot_title, col="blue")
abline(0,0)

points(final$event_bl[ld],timeDif1[ld],pch=19,col="red")

# define file name (goes in the mission folder)
fn=file.path(outpath,paste0(mission,"_time_check_QAT_ODF.png"))

dev.copy(png,fn, width=700,height=600, res=90)
dev.off()

sink(file=report_file,append=TRUE, split=TRUE)
if (length(ld)>0) {  
  cat("\n","\n")
  cat("-> Time difference between QAT time and ODF start time > 20 min:")
  cat("\n","\n")
  print(final[ld,c("event_qat","start_date_time_odf","date_time_qat","Initial_Latitude_odf","lat_qat","Initial_Longitude_odf","lon_qat")] )
}
sink()

# -----------------------------------------------------#
# check DEPTH from BiolSums and Pressure from QAT file #
# -----------------------------------------------------#

# difference between BiolSums Depth and pressure in qat file
depthDif=final$depth_bs - final$pressure_qat
plot_title=paste("Depth check: BiolSum Depth vs. QAT pressure","\n",qat_header$cruise_qat[1])


# identify depth difference of more than 5m or 3%
depth_lim=pmax(5,final$depth_bs*0.03, na.rm=TRUE)
dd5=which(abs(depthDif) > depth_lim)

# ----write comments on the screen and to the file----
sink(file=report_file,append=TRUE, split=TRUE)
# print info for the casts exceeding limits
if (length(dd5)>0) {
  cat("\n","\n")
  cat("-> DEPTH CHECK: BiolSum depth and QAT presure difference >5m or >3% for following casts, BiolSums depth replaced with QAT pressure:")
  cat("\n","\n")
  print(final[dd5, c("event_qat","event_qat","id_bs","ctd_bs","depth_bs","pressure_qat")])   
} else {
  cat("\n","\n")
  cat("-> DEPTH CHECK: BiolSum depth and QAT pressure difference <5m or <3%.")
}
sink()
# --- done with coments ---


plot(final$event_qat,depthDif, xlab="Event Number", ylab="BiolSum depth  -  QAT Pressure  [m]", 
     main=plot_title, col="blue")
points(final$event_qat[dd5],depthDif[dd5], pch=19, col="red")
abline(0,0)

#legend("bottomleft",legend=c(paste0("difference > ",depth_lim,"m")),col=c("red"),
#       pch=c(NA,19),bty="n")

# define file name (goes in the mission folder)
fn=file.path(outpath,paste0(mission,"_depth_check.png"))

dev.copy(png,fn, width=700,height=600, res=90)
dev.off()

# plot depth difference as a function of BIOLsUMS depth
plot(final$depth_bs,depthDif, xlab="BiolSum depth [m]", ylab="BiolSum depth  -  QAT Pressure  [m]", 
     main=plot_title,col="blue")
points(final$depth_bs[dd5],depthDif[dd5], pch=19, col="red")
abline(0,0)
#legend("bottomleft",legend=c(mission,paste0("difference > ",depth_lim,"m")),col=c(NA,"red"),
#       pch=c(NA,19),bty="n")

# define file name (goes in the mission folder)
fn=file.path(outpath,paste0(mission,"_depth_check1.png"))

dev.copy(png,fn, width=700,height=600, res=90)
dev.off()


# Replace biolsums depth with QAT pressure for outliers
if(length(dd5) > 0){
  
  # loop through dd5
  for(i in 1:length(dd5)){
    
    # Replace biolsums depth with QAT pressure
    final[dd5[i],'depth_bs'] = final[dd5[i],'pressure_qat']
    
  } # End for loop
  
} # End if statement


# ------------------------------------------------#
# check SOUNDING: ODF vs. GEBCO bathymetry
# ------------------------------------------------#

final$Sounding_odf=as.numeric(final$Sounding_odf) #sometimes the sounding is character

# replace -99.9 or sounding < 10 with NA in ODF sounding
final$Sounding_odf[which(final$Sounding_odf < 20)]=NA
#soundingDif= final$sounding_bl - final$Sounding_odf

# check sounding vs. GEBCO bathymetry: get depth range in 0.1 deg box around station location
# use gebco_depth_range.r custom made function and bridge log position
dr=gebco_depth_range(final$lat_qat,final$lon_qat)

# merge bathymetry range with final data
sound=merge(final[,c("ctd_bs","event_qat", "station_bs","lat_qat","lon_qat","Sounding_odf")],dr, by.x=c("lat_qat","lon_qat"), by.y=c("slat","slon"))

# look at CTD casts only
sound=unique(sound[!is.na(sound$ctd_bs),])


# if there is bridge log sounding then check versud GEBCO depths
if(!all(is.na(final$Sounding_odf))) {
  
  
  # write out the casts that are out of range
  outs=which(sound$Sounding_odf< sound$min_gebco | sound$Sounding_odf> sound$max_gebco)
  
  sink(file=report_file,append=TRUE, split=TRUE)
  if (length(outs)>0) {
    cat("\n","\n")
    cat("-> Warrning: ODF Sounding out of GEBCO range (0.1deg around location):")
    cat("\n","\n")
    print(sound[outs,])
  } else {
    cat("-> All ODF Sounding within GEBCO range in 0.1deg box around location.")
  }
  sink()
  
} else {
  cat("\n","\n")
  cat("-> Sounding Check not completed: No sounding data in the ODF file.")
}

#-----------------------------------#
# Check if the stations are on land
#-----------------------------------#

# indices of the stations on land
iland=which(sound$gebco_sounding<0)


sink(file=report_file,append=TRUE, split=TRUE)
if (length(iland)>0) {
  cat("\n","\n")
  cat("-> Warrning: Station might be on land:")
  cat("\n","\n")
  print(sound[iland,])
} else {
  cat("\n","\n")
  cat("-> No stations on land.")
}
sink()

# done with checks

# =============================== #
# GET MISSION INFO FOR THE HEADER #
# =============================== #

oscFile <- read.csv('Cruise_fixed_Stns.csv', stringsAsFactors = F)
osc <- oscFile[ (oscFile$MISSION_NAME == mission) | (oscFile$MISSION_NAME == gsub('BCD19','',mission)), ]
remove(oscFile)

osc_info=osc[,!names(osc) %in% c("MISSION_DESCRIPTOR","LEG")] # remove MISSION_DESCRIPTOR and LEG column
tosc=t(osc_info) # transposed osc info table

# columns in ODF ile for the header
odfc=c("Cruise_Number","Platform","Start_Date","End_Date","Organization","Chief_Scientist","Cruise_Name","Cruise_Description")

odf_info=odf_info[1,odfc]
todf=t(odf_info) #transposed odf info table

# have the same titles for the columns
names(odf_info)=names(osc_info)

# compare start and end date
sdd=difftime(as.Date(osc_info$MISSION_SDATE,tryFormats = c("%d-%b-%Y")),as.Date(format_date(odf_info$MISSION_SDATE),"%d-%b-%Y"))
edd=difftime(as.Date(osc_info$MISSION_EDATE,tryFormats = c("%d-%b-%Y")),as.Date(format_date(odf_info$MISSION_EDATE),"%d-%b-%Y"))


sink(file=report_file,append=TRUE, split=TRUE)
cat("\n","\n")
cat("-> Mission information from osccruise database:")
cat("\n","\n")
print(tosc)
cat("\n","\n")
cat("-> Mission information from ODF metadata:")
cat("\n","\n")
print(todf)

if (abs(sdd) >0) {
  cat("\n","\n")
  sm=paste("-> Warrning:", abs(sdd), "days difference in MISSION START DATE. Check cruise report for correct dates.")
  cat(sm)
}

if (abs(edd) >0) {
  cat("\n","\n")
  sm=paste("-> Warrning:",abs(edd), "days difference in MISSION END DATE. Check cruise report for correct dates.")
  cat(sm)
}

sink()


make_header=askYesNo("Would you like to create BCS HEADER file?")

if (make_header==T) {
  
  sink(file=report_file,append=TRUE, split=TRUE)
  cat("\n","\n")
  cat(paste("Creating BCS Header file for", mission))
  cat("\n","\n")
  sink()
  
  # ====================#
  # CREATE HEADER FILE 
  # ====================#
  
  # one option is to type unknown fields on the screen
  ## 666 is HL_02 (Scotian Shelf), 668 is Shediac, 669 is P_05 (Bay of Fundy)
  created_by=ginput("Input your first and last name (person processing the data):")
  
  # # the other option is to read the data from the "files" (excel file with cruise info)
  # protocol=files$mission_protocol
  # header_collector=files$header_collector
  # responsible_group=files$responsible_group
  institute="BIO" #institute is hard coded but can be changed in the script
  platform="Various" # Hardcoded for Fixed Stations to be various
  
  other_mission = other[other$Fixed.Station == mission,] # Other mission names and descriptors that are contained in this fixed stations data
  
  header=NULL
  
  header$MISSION_DESCRIPTOR=sample(cruise_info$ISDM.mission.ID, nrow(final), replace = TRUE)  # pulled from cruise list reboot file
  header$EVENT_COLLECTOR_EVENT_ID=final$event_qat                         # event from QAT/ODF
  
  for(i in 1:length(header$MISSION_DESCRIPTOR)){
    
    if(header$EVENT_COLLECTOR_EVENT_ID[i] %in% other_mission$Event.Number){
      
      header$MISSION_DESCRIPTOR[i] = other_mission[other_mission$Event.Number == header$EVENT_COLLECTOR_EVENT_ID[i], 'Meds.mission.number']
      
    }
    
  }
  
  if(grepl(666, mission) == TRUE){station = 'HL_02'}
  if(grepl(668, mission) == TRUE){station = 'SHED'}
  if(grepl(669, mission) == TRUE){station = 'P_05'}
  header$EVENT_COLLECTOR_STN_NAME=station                                 # HARD CODE STATION, Check with Andrew
  
  header$MISSION_NAME = sample(mission, length(header$EVENT_COLLECTOR_EVENT_ID), replace = TRUE)  # Usually mission, but may be other cruise
  for(i in 1:length(header$MISSION_NAME)){
    
    if(header$EVENT_COLLECTOR_EVENT_ID[i] %in% other_mission$Event.Number){
      
      header$MISSION_NAME[i] = other_mission[other_mission$Event.Number == header$EVENT_COLLECTOR_EVENT_ID[i], 'Cruise']
      
    }
    
  }
  
  header$MISSION_LEADER=tosc["MISSION_LEADER",]                           # Mission leader from OSC
  header$MISSION_SDATE=format_date(paste0(yr,'-01-01'))                   # HARD CODE January 1 of year   
  header$MISSION_EDATE=format_date(paste0(yr,'-12-31'))                   # HARD CODE December 31 of year
  header$MISSION_INSTITUTE=institute                                      # mission institute is BIO (hardcoded)
  header$MISSION_PLATFORM=platform                                        # platform is Various for Fixed Stations (hardcoded)
  header$MISSION_PROTOCOL='AZMP'                                          # HARD CODE AZMP
  
  if(grepl(666, mission) == TRUE){region = 'SCOTIAN SHELF'}
  if(grepl(668, mission) == TRUE){region = 'SHEDIAC VALLEY, SOUTHERN GULF'}
  if(grepl(669, mission) == TRUE){region = 'BAY OF FUNDY'}
  header$MISSION_GEOGRAPHIC_REGION=region                                 # HARD CODE REGIONS
  
  header$MISSION_COLLECTOR_COMMENT1=""                                    # was originally from osccruise but is left blank for now 
  header$MISSION_COLLECTOR_COMMENT2=""                                    # empty
  header$MISSION_DATA_MANAGER_COMMENT="Maritimes BioChem Reload"          # hardcoded
  
  header$EVENT_SDATE=format(final$event_sdate_stime,"%d-%b-%Y")           # start date from CTD 
  header$EVENT_EDATE=format(final$event_sdate_stime,"%d-%b-%Y")           # same as sdate
  header$EVENT_STIME=bctime(final$event_sdate_stime)                      # start time from CTD in HHMM FORMAT
  header$EVENT_ETIME=bctime(final$event_sdate_stime)                      # same as sdate
  header$EVENT_MIN_LAT=round(pmin(final$lat_qat, na.rm=T), digits=6)      # min start lat from last bottle QAT file lat
  header$EVENT_MAX_LAT=round(pmax(final$lat_qat, na.rm=T), digits=6)      # max start lat from last bottle QAT file lat
  header$EVENT_MIN_LON=round(pmin(final$lon_qat, na.rm=T), digits=6)      # min start lon from last bottle QAT file lon
  header$EVENT_MAX_LON=round(pmax(final$lon_qat, na.rm=T), digits=6)      # max start lon from last bottle QAT file lon
  header$EVENT_UTC_OFFSET=0                                               # hard coded
  header$EVENT_COLLECTOR_COMMENT1 = sample('', length(header$MISSION_NAME), replace = TRUE) # Usually empty, but contains ODF cruise name when not a fixed station cruise
  for(i in 1:length(header$EVENT_COLLECTOR_COMMENT1)){
    
    if((header$EVENT_COLLECTOR_EVENT_ID[i] %in% other_mission$Event.Number) & (length(odf_full[odf_full$Event_Number == header$EVENT_COLLECTOR_EVENT_ID[i], 'Cruise_Name']) > 0 )){
      
      header$EVENT_COLLECTOR_COMMENT1[i] = odf_full[odf_full$Event_Number == header$EVENT_COLLECTOR_EVENT_ID[i], 'Cruise_Name']
      
    }
    
  }
  header$EVENT_COLLECTOR_COMMENT2= ""                                     # empty
  
  ctd_miss_mission = ctd_miss[ctd_miss$Mission == mission,]
  header$EVENT_DATA_MANAGER_COMMENT= sample('', length(header$MISSION_NAME), replace = TRUE) # Usually empty, lists cruises with no CTD data
  for(i in 1:length(header$EVENT_DATA_MANAGER_COMMENT)){
    
    if(header$EVENT_COLLECTOR_EVENT_ID[i] %in% ctd_miss_mission$Event.Number){
      
      header$EVENT_DATA_MANAGER_COMMENT[i] = 'No CTD Data - Latitude Longitude Time and Date may be inaccurate'
      
    }
    
  }
  
  header$EVENT_COLLECTOR_EVENT_ID=sprintf('%03d',round(final$event_qat, digits = 0))  # event from QAT/ODF,convert to string and add leading zeroes
  
  header$DIS_HEADR_GEAR_SEQ=final$GEAR_SEQ_bs                             # assigned in check_biolsum1, for bottle data 90000019, ctd only 90000065
  header$DIS_HEADR_SDATE=format(final$date_time_qat,"%d-%b-%Y")           # date from QAT file 
  header$DIS_HEADR_EDATE= header$DIS_HEADR_SDATE                          # end date is same as start date (from QAT file)
  header$DIS_HEADR_STIME=bctime(final$date_time_qat)                      # time from QAT file (each bottle has different time)
  header$DIS_HEADR_ETIME=header$DIS_HEADR_STIME                           # end time is same as start time (from QAT file)
  header$DIS_HEADR_TIME_QC_CODE=0  #empty                                 # !!!! TO BE DECIDED - WHEN TO ASSIGN FLAGS???
  header$DIS_HEADR_SLAT=round(final$lat_qat, digits=6)                    # lat from QAT file
  header$DIS_HEADR_ELAT=round(header$DIS_HEADR_SLAT, digits=6)            # end lat same as start lat (from QAT file)
  header$DIS_HEADR_SLON=round(final$lon_qat, digits=6)                    # lon from QAT file
  header$DIS_HEADR_ELON=round(header$DIS_HEADR_SLON, digits=6)            # end lon same as start lon (from QAT file)
  header$DIS_HEADR_POSITION_QC_CODE=0                                     # !!!! TO BE DECIDED- WHEN TO ASSIGN FLAGS???
  header$DIS_HEADR_START_DEPTH=final$depth_bs                             # Bottle depth from BiolSum for bottle and CTD or QAT pressure for CTD data only
  header$DIS_HEADR_END_DEPTH=header$DIS_HEADR_START_DEPTH                 # end bottle depth same as start bottle depth (from BiolSum)
  header$DIS_HEADR_SOUNDING=final$Sounding_odf                            # Sounding from ODF
  header$DIS_HEADR_COLLECTOR_DEPLMT_ID= ""                                # empty
  header$DIS_HEADR_COLLECTOR_SAMPLE_ID=final$id_bs                        # Sample ID from BiolSum
  header$DIS_HEADR_COLLECTOR='AZMP'                                       # Hard code to AZMP
  header$DIS_HEADR_COLLECTOR_COMMENT1="End depth=Start depth; Start depth is nominal"
  header$DIS_HEADR_DATA_MANAGER_COMMENT="BioChem reload, QC performed using modified IML protocols."
  header$DIS_HEADR_RESPONSIBLE_GROUP='AZMP'                               # Hard coded to AZMP
  header$DIS_HEADR_SHARED_DATA=""                                         # empty
  header$CREATED_BY=created_by                                            # INPUT BY USER
  header$CREATED_DATE=now()                                               # system date and time when header is created
  header$DATA_CENTER_CODE=20                                              # hard coded, 20 means BIO
  header$PROCESS_FLAG="NR"                                                # hard coded
  header$BATCH_SEQ=""                                                     # empty, will be assign when loaded
  
  
  
  
  
  # next construct DIS_SAMPLE_KEY_VALUE
  id=header$DIS_HEADR_COLLECTOR_SAMPLE_ID       # constructed using mission, event and sample ID
  id[which(is.na(id))]="0"
  DIS_SAMPLE_KEY_VALUE=paste0(header$MISSION_NAME,"_",header$EVENT_COLLECTOR_EVENT_ID,"_",id)
  
  # header is a list. convert list to data frame
  h=data.frame(header, stringsAsFactors=FALSE)
  
  # add DIS_SAMPLE_KEY_VALUE to the first column
  h=cbind(DIS_SAMPLE_KEY_VALUE,h)
  
  # replace comments if the samples are CTD only (no bottle data)
  # iiii=which(h$DIS_HEADR_GEAR_SEQ == 90000065)
  h$DIS_HEADR_COLLECTOR_COMMENT1[which(h$DIS_HEADR_GEAR_SEQ == 90000065)]="End depth=Start depth; Start depth is pressure from CTD QAT file"  
  h$DIS_HEADR_DATA_MANAGER_COMMENT[which(h$DIS_HEADR_GEAR_SEQ == 90000065)]="BioChem reload, QC performed using modified IML protocols. No bottle data."
  
  # lat and lon should be 6 decimal places
  
  
  # export to csv file
  of=file.path(outpath,paste0(mission,"_BCS_test.csv"))
  
  # Local write
  write.csv(h,of,row.names=FALSE,na="")
  write.table(h,paste0(outpath, '/', mission,"_BCS_test.txt"), sep="\t",na="")
  
  # Shared Write
  #write.csv(h, paste0(files$path, '/QC/', mission, '_BCS_test.csv'), row.names=FALSE, na='')
  #write.table(h,paste0(files$path, '/QC/', mission, '_BCS_test.txt'), sep="\t",na="")
}

# done with saving header file



