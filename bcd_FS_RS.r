# merge BuiChem historical data and create BCD table
# Gordana Lazin, BioChem Reboot project, 22-Apr-2016
# Edited for Fixed stations by Claudette Landry, Aug-2019
# Continued editing for fixed stations by Reid Steele, June 2020
# Contains code to write to the shared drive or a local directory
# Mission can be commented out if writing BCS and BCD files in succession



wd="C:/Users/steeler/Documents/Reid/BCD Creation/Fixed Station Biochem Reload/convertingtoBCDBCS/FS BCD BCS" 
setwd(wd)

require(xlsx)
require(tidyr)
require(readxl)
require(lubridate)
require(reshape)
require(gWidgets2tcltk)
source("format_time.r")
source("format_date.r")
source("osccruise.r")
source("gebco_depth_range_CL.r")
source("na.rows.r")
source("na.columns.r")
source("rename_stations.r")
source("bctime.r")
source("substrRight.r")
source("clean_xls.r")
source("check_biolsum1_CL.r")
source("check_bridgeLog.r")
source("check_qat1.r")
source("check_ctd_metadata_CL.r")
source("clr.r")
source("mkdirs.r")
source("mission_info_CL.r")
source("is.installed.r")
source("correct_oxy.r")
source("find_outliers.r")
source("axis_range.r")
source("compare_sensors_RS.r")
source("get_dataseq.r")
source("choose_qat_sensors_CL.r")
source("check_qat_ranges.r")
source("stack_bcdata_EC.r")

# 30/41 BCDs generated (RS 7/17/2020):
  # BCD1999666
  # BCD2000668
  # BCD2000669
  # BCD2001668
  # BCD2002666
  # BCD2002668
  # BCD2003666
  # BCD2003669
  # BCD2004666
  # BCD2004668
  # BCD2004669
  # BCD2005666
  # BCD2005668
  # BCD2005669
  # BCD2006666
  # BCD2006668
  # BCD2006669
  # BCD2007666
  # BCD2007668
  # BCD2007669
  # BCD2008668
  # BCD2008669
  # BCD2009666
  # BCD2009668
  # BCD2009669
  # BCD2010669
  # BCD2011666
  # BCD2012666
  # BCD2012669
  # BCD2013666


mission="BCD2005668"

# Create a folder in the working directory for the mission
missiondir=file.path(getwd(),'Output_RS',mission)
dir.create(missiondir, showWarnings = FALSE)

fp="C:/Users/steeler/Documents/Reid/BCD Creation/Fixed Station Biochem Reload/convertingtoBCDBCS/FS BCD BCS/fixed_station_files_RS.csv"
files=read.csv(fp, stringsAsFactors=FALSE)

# select files for this particular mission
files=files[files$mission==mission,]

# Fix paths to work with shared drive
files$path = gsub('//ent.dfo-mpo.ca/ATLShares', 'R:/', paths$path)

BiolSum=file.path(files$Biolpath,files$Biolsumedit)
qatFile=file.path(files$newqatpath,files$newqat)
odfFile=file.path(files$path,files$odf)

# because some of the dates in Biolsums are accounted for in other cruises this file containing the accounted for cruise dates 
# needs to be read in so that the dates can be removed from the biolsums while processing
acfs<-"C:/Users/steeler/Documents/Reid/BCD Creation/Fixed Station Biochem Reload/Accounting for ODF/accounted for dates and cruises.csv"
accounted<-read.csv(acfs)
accounted=accounted[accounted$BCD_cruise==mission,]
accounted$Biolsum_date=format_date(accounted$Biolsum_date)

# ======== #
# BiolSum
# ======== #


# read BiolSum
bsum=read.csv(BiolSum, stringsAsFactors=FALSE)
bsum=clean_xls(bsum) # clean excel file

# compare and remove dates accounted for in other cruises like AZMP and Groundfish
bsum=bsum[which(!bsum$sdate %in% accounted$Biolsum_date),]

# Remove CTD only rows (many variations)
bsum = bsum[!(bsum$id %in% c('CTD ONLY', 'CTD', 'CTD ', 'ONLY', 'Only', 'Only!', 'CTD only')),]

# define columns with metadata
bsum_meta=c("ctd","depth","event","station","sdate","stime","slat","slon","doy","slat_deg","slat_min","slon_deg","slon_min")

# keep only data column
bsum=bsum[,!(names(bsum) %in% bsum_meta)]

# fix the header. excel reader reads - as . for some reason
names(bsum)=gsub("Holm.Hansen","Holm-Hansen",names(bsum))

# find electrode oxy data
oe=which(names(bsum) %in% c("O2_Electrode","o2_um"))

# if there is electrode % saturation or umol data remove those column
if (length(oe>0)) {
  bsum=bsum[,-oe]
}

# rename o2_mll and o2_ml to electrode mll datatype
mll=which((names(bsum)=="o2_mll") | (names(bsum)=="o2_ml"))


if (length(mll)>0) {
  names(bsum)[mll]="O2_Electrode_mll"
}

# make stacked dataset with data type sequences using stack_bcdata function
mbs=stack_bcdata_EC(bsum)



# ======== #
# QAT file #
# ======== #

# read QAT file
qat=read.csv(qatFile,stringsAsFactors=FALSE, strip.white=TRUE)

# ======================== #
# QAT Edits and Typo Fixes #
# ======================== #

# BCD1999666 - Remove IDs accounted for in PAR1998078
if(mission == 'BCD1999666'){
  qat = qat[!(qat$id %in% 201211:201220),]
}

# BCD2007668 - Remove IDs accounted for in HUD2007666
if(mission == 'BCD2007666'){
  qat = qat[!(qat$id %in% 310454:310465),]
}

# define columns with metadata
qat_meta=c("ctd_file","cruise","event","lat","lon","trip","date","time")

# keep only data column
qat=qat[,!(names(qat) %in% qat_meta)]

# remove columns only containing NAs
qat=qat[,-na.columns(qat)]

# visually compare sensors in qat file and save the plots
compare_sensors(qat,mission)
cat("\n","\n")
cat(" *********** PLEASE EXAMINE SENSOR COMPARISON PLOTS *********** ")
cat("\n","\n")

op=gconfirm("Are you ready to continue (y or n)?: ")

if (op==F) {
  
  stop()
}

# check ranges of qat data for temp, sal, oxy
check_qat_ranges(qat)

# choose primary or secondary sensors. 
# Output is list that contains a dataframe and name of original sensors.
ll=choose_qat_sensors(qat)

qf=ll$qf #qf is dataframe with qat data that has only one sensor for each parameter
original_sensors=ll$original_sensors # contains names with choices of original sensors


# =============== #
#  OXY correction
# =============== #

# introduce oxy_flag to track if oxy correction
# oxy_flag=0 no oxy correction was made to qat file
# oxy_flag=1 oxy correction is aplied to qat oxy using winkler
oxy_flag=0
 
# check if BiolSum has o2_winkler

wb=grep("winkler",names(bsum),ignore.case=TRUE)

# if winkler exsists proceede with correction

if (length(wb)>0) {
  
  
  #  merge biolsum and qat based on the sample ID
  bsq=merge(bsum,qf, by.x="id",by.y="id", all=TRUE)
  
  # find out which oxy sensor is in qat file. 
  # This works for qat file that has oxy1, oxy2 or just oxy
  oxs=names(qf)[grep("oxy",names(qf))] # name of the oxy sensor (oxy1 or oxy2 or oxy)
  oxy_sensor=gsub("[[:alpha:]]","",original_sensors[grep("oxy",original_sensors)]) # original oxy sensor
  
  # define winkler and ctd oxy vectors
  winkler=bsq[,grep("winkler",names(bsq),ignore.case=TRUE)]
  ctd_oxy=bsq[,grep("oxy",names(bsq))]
  
  # correct CTD oxy sensor using "correct_oxy.r" function
  # corrected oxy is oxyc
  bsq$oxyc=correct_oxy(ctd_oxy,winkler, mission,oxy_sensor=oxy_sensor) 
  
  # add corrected oxy to qat dataframe qf
  qfc=merge(bsq[,c("id","oxyc")],qf,by="id",all.x=T,all.y=T)
  
  # replace original qat oxy with corrected oxy
  qf$oxy=qfc$oxyc
  
  oxy_flag=1
  
}

# qf is final qat file that has only one column for each sensor.
# the sensors used for each variable are stored in the "original_sensors" variable
# if correction of CTD oxygen data is applied using winkler "oxy_flag" is set to 1
# if there was no CTD oxy correction "oxy_flag" is set to 0

# ------------------------------------ #
# RENAME QAT SENSORS TO BIOCHEM METHOD #
# ------------------------------------ #

sensors=c("oxy","sal","temp","cond","fluor")

# rename qat sensors to to BioChem names
qatnames=c(sensors,"pressure","ph","par")
bcnames=c("O2_CTD_mLL","Salinity_CTD","Temp_CTD_1968","conductivity_CTD",
          "Chl_Fluor_Voltage","Pressure","pH_CTD_nocal","PAR")

# find corresponding columns
ni=match(names(qf),qatnames)

# rename qat clumns with bcnames
mn=which(!is.na(ni)) # matching names

# create dataframe containing data mapping info
cc=as.data.frame(cbind(names(qf)[mn],bcnames[ni[mn]]))
names(cc)=c("qat_column_name","BioChem_Method")

cat("\n",'\n')
cat("Assigning following BioChem datatypes to QAT columns:")
cat("\n",'\n')
print(cc)

names(qf)[mn]=bcnames[ni[mn]]

# stack data in biochem format
# qss is QAT data stacked
qss=stack_bcdata_EC(qf)

# DONE WITH QAT DATA  #
# =================== #



# =================== #
#   CREATE BCD FILE
# ------------------- #

# 1. put all stacked data together

# qss is stacked QAT file
# mbs is stacked biolsum data

ff=rbind(qss,mbs) # all data together

# rename the columns to proper names
names(ff)=gsub("variable","DATA_TYPE_METHOD",names(ff))
names(ff)=gsub("value","DIS_DETAIL_DATA_VALUE",names(ff))




# 2. merge data with metadata in BCS file by sample ID
# load bcs_header file

# file name with path
pbcs=file.path(getwd(),paste0('Output_RS/',mission,'/',mission,"_BCS_test.csv"))

# load BCS file
bcs=read.csv(pbcs,1)

# check if there is any difference in IDs between BCS and data file
diff=setdiff(unique(bcs$DIS_HEADR_COLLECTOR_SAMPLE_ID),unique(ff$id))

# merge BCS and data file by sample ID
mf=merge(bcs,ff, by.x="DIS_HEADR_COLLECTOR_SAMPLE_ID",by.y="id", all=TRUE)

# check if all the samples have values
which(is.na(mf$DIS_DETAIL_DATA_VALUE))

# add columns for BCD file
mf$DIS_DATA_NUM=seq(1,dim(mf)[1],1)
mf$DIS_DETAIL_DATA_QC_CODE=0
mf$DIS_DETAIL_DETECTION_LIMIT=NA
mf$PROCESS_FLAG="NR"
mf$BATCH_SEQ=0
mf$CREATED_BY=("Reid Steele")
mf$CREATED_DATE=as.character(now())


# 3. make BCD data file: order the columns and rename if necessary

# name of the columns for BCD file
cols=c("DIS_DATA_NUM","MISSION_DESCRIPTOR","EVENT_COLLECTOR_EVENT_ID","EVENT_COLLECTOR_STN_NAME",
     "DIS_HEADR_START_DEPTH","DIS_HEADR_END_DEPTH","DIS_HEADR_SLAT","DIS_HEADR_SLON",
     "DIS_HEADR_SDATE","DIS_HEADR_STIME","DATA_TYPE_SEQ","DATA_TYPE_METHOD","DIS_DETAIL_DATA_VALUE",
     "DIS_DETAIL_DATA_QC_CODE","DIS_DETAIL_DETECTION_LIMIT","DIS_HEADR_COLLECTOR","DIS_HEADR_COLLECTOR_SAMPLE_ID",
     "CREATED_BY","CREATED_DATE","DATA_CENTER_CODE","PROCESS_FLAG","BATCH_SEQ","DIS_SAMPLE_KEY_VALUE")

# match orcer of BCD columns to the col vector
mm=match(cols,names(mf))

# BCD file is created with proper order of the columns
bcd=mf[,mm]

# rename specific fields

# rename:
names(bcd)[which(names(bcd)=="DIS_HEADR_COLLECTOR")]="DIS_DETAIL_DETAIL_COLLECTOR"
names(bcd)[which(names(bcd)=="DIS_HEADR_COLLECTOR_SAMPLE_ID")]="DIS_DETAIL_COLLECTOR_SAMP_ID"
names(bcd)[which(names(bcd)=="DATA_TYPE_SEQ")]="DIS_DETAIL_DATA_TYPE_SEQ"


# replace HEADR with HEADER
names(bcd)=gsub("HEADR","HEADER",names(bcd))

# Change 'no sample', 'lost samp', 'No', and '' to NA
bcd$DIS_DETAIL_DATA_VALUE = ifelse(bcd$DIS_DETAIL_DATA_VALUE %in% c('no sample', 'lost samp', 'No', ''), NA, bcd$DIS_DETAIL_DATA_VALUE)

# Remove NAs and fix DIS_DATA_NUM
bcd = bcd[is.na(bcd$DIS_DETAIL_DATA_VALUE) == FALSE, ]
bcd$DIS_DATA_NUM=seq(1,dim(bcd)[1],1)

# now bcd file is ready
# save bcd file
outpath=file.path(wd,'Output_RS',mission)
bcd_filename=file.path(outpath,paste0(mission,"_BCD_test.csv"))

# Local Write
write.csv(bcd, bcd_filename, row.names=FALSE)

# Shared Write
#write.csv(bcd, paste0(files$path, '/QC/', mission, '_BCD_test.csv', row.names=FALSE))

cat("\n","\n")
cat(paste("Created BCD for", mission))
cat("\n","\n")

#    DONE WITH BCD FILE    #
# ======================== #



# Also, work on CHN data renaming and formating

# merge bsq with HPLC data
#bsqh=merge(bsq,hplc,by.x="id",by.y="ID",all=TRUE)
