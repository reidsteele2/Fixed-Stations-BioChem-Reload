Reid Steele, Aug 11 2020

Questions can be addressed to reid.steele@dfo-mpo.gc.ca

This folder contains necessary R scripts/functions, file dependancies, input directories, and output directories for generating BCS and BCD files for fixed stations missions at:
Halifax Line 2 + Prince 5 from 1999 to 2013, Shediac from 1999 to 2009

The current contents of this folder are as follows:

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Directories:

1. original biolsums - contains biolsums from the 1_REBOOT folder of each fixed stations mission

2. corrected biolsums - contains biolsums edited from the original biolsums by fixing_Biolsums_RS.R to prepare biolsums for reading into R for BCS and BCD creation. These biolsums can also be found in the 1_REBOOT folder of each mission.

3. GEBCO_2020_24_Jun_2020_a50fd4cc5f31 - contains GEBCO sounding information from 80N - 35S and -100W - -40E, used for sounding quality control in bcs_fs1_CL_RS.r.

4. NEWQATS - Archive - contains unedited concatenated QAT files created by Diana Cardoso. To my knowledge, these QAT files do not exist anywhere else. 

5. NEWQATS_RS - contains edited versions of the files in NEWQATS - Archive after modification by FilePaths_QATHeaders_RS.R. These QATs can also be found in the 1_REBOOT folder of each mission.

6. QATS_to_add - contains QAT files which were not concatenated as part of the files in NEWQATS - Archive, and which are added to the files in NEWQATS_RS by FilePaths_QATHeaders_RS.R. Also contains QAT_filenames.csv.

7. ODF archive - contains unedited CTD metadata files, which are used by ctd_metadata_add_cruises_RS.R to create the final files contained in ODF files.

8. ODF files - contains edited CTD metadata files, created by ctd_metadata_add_cruises_RS.R using the files in ODF archive and ODF_to_add. These CTD metadata files can also be found in the 1_REBOOT folder of each mission.

9. ODF_to_add - contains ODF files which were not concatenated as part of the files in ODF archive, and which are added to the files in ODF files by ctd_metadata_add_cruises_RS.R. Also contains ODF_filenames.csv.

10. R functions - contains R scripts which contain functions used by the main R scripts in this folder.

11. Output_RS - contains the outputs from bcs_fs1_CL_RS.r and bcd_FS_RS.r for each mission. These folders are identical to the QC folders in the 1_REBOOT folder of each cruise (this will only be true until QC is complete).

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Files:

1. accounted for datas and cruises.csv - list of dates on which a fixed station was sampled as part of a cruise which is already loaded into BioChem. Used by bcs_fs1_CL_RS.r and bcd_FS_RS.r to remove data that is already loaded into 
biochem from BiolSums. Contains fixed station mission number, date, and cruise name. Note - if editing this file, be sure to format the date cells into dd-mm-yyyy format before saving. If not done, the dates will load into R incorrectly.

2. fixed_station_files.csv - contains an unedited list of file paths and file names of required files for fixed stations BCD and BCS creation. Also serves as a list of fixed stations missions in reboot. Used by FilePaths_QATHeaders_RS.R.

3. fixed_station_files_RS.csv - an edited version of fixed_station_files.csv created by FilePaths_QATHeaders_RS.R and used in all other main R scripts.

4. FS_Missing_QAT_Data.xlsx - list of CTD casts for which there is missing QAT data. Contains fixed station mission number, event date, event number, affected sample IDs, and a short description. Sheet 1 contains events for which there
is no CTD data at all, while sheet 2 contains events for which there is ODF data but not QAT data. Sheet 1 is used by bcs_fs1_CL_RS.r to comment that latitude, longitude, date, and time may be incorrect due to missing ctd data.

5. other_cruises.csv - list of events in which a fixed station was sampled by a non-reboot cruise. In such cases, the data is being loaded as part of fixed stations, but the mission number and descriptor will come from the cruise.
Contains fixed station mission name, cruise number, event number, and cruise descriptor (MEDS mission number). Event numbers with decimal places indicate that the event number is used by both the cruise and the fixed station mission.
They are intentional, and they are removed later in BCS/BCD creation. Used by bcs_fs1_CL_RS.r to set mission names and descriptors for the events in the file. 

6. QAT_filenames.csv (in QATS_to_add_ - list of files in QATS_to_add, the fixed station missions they belong to, and the names of the cruises they belong to. Used by FilePaths_QATHeaders_RS.R to concatenate the QAT files in 
NEWQATS - Archive with the QAT files in QATS_to_add.

7. ODF_filenames.csv (in ODF_to_add) - list of files in ODF_to_add, the fixed station missions they belong to, and the names of the cruises they belong to. Used byctd_metadata_add_cruises_RS.R to concatenate the CTD metadata files in 
ODF archive with the ODF files in ODF_to_add.

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Main R Scripts:

1. ctd_metadata_add_cruises - concatenates ODF files in ODF_to_add with files in ODF archive using ODF_filenames.csv, outputs to ODF files and/or individual 1_REBOOT files on the shared drive. Edits to ODF should be made to ODF Archive
or code, not ODF files. If edits to CTD metadata are made, fix in ODF archive or code then rerun code to fix ODF Files.

2. FilePaths_QATHeaders_RS.R - concatenates QAT files in QATS_to_add with files in NEWQATS - Archive using QAT_filenames.csv, outputs to NEWQATS_RS and/or individual 1_REBOOT files on the shared drive. Also edits fixed_station_files.csv
and outputs fixed_station_files_RS.csv, used to generate local file names/file paths for fixed_station_files_RS.csv. Edits to QATs should be made to biolsums in NEWQATS - Archive or code, not NEWQATS_RS. If edits to QATs are made,
fix in NEWQATS - Archive then rerun code to fix corrected biolsums.

3. fixing_Biolsums_RS.R - edits biolsums in original biolsums to create biolsums in corrected biolsums, which are used by bcs_fs1_CL_RS.r and bcd_FS_RS.r for BCS and BCD creation respectively. Can output to corrected biolsums and/or
individual 1_REBOOT files on the shared drive. Edits to biolsums should be made to biolsums in original biolsums, not corrected biolsums. If edits to biolsums are made, fix in original biolsums then rerun code to fix corrected biolsums.

4. bcs_fs1_CL_RS.r - creates BCS file and performs many QC checks, including comparing dates, times, latitudes, and longitudes across files, checking sounding, checking for stations on land, and comparing depth between QAT and BiolSums.
Outputs BCS files, as well as some QC plots when necessary. Outputs to Output_RS and/or individual 1_REBOOT/QC folders on the shared drive.

5. bcd_FS_RS.r - creates BCD files and performs sensor comparison when there are multiple CTD sensors for the same method in the QAT file. Outputs BCD files, as well as sensor comparison plots when relevant. Outputs to Output_RS and/or
individual 1_REBOOT/QC folders on the shared drive. 

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Documentation:

1. Fixed Stations BCS Creation Issue Log.docx - contains a log of all the issues I encountered while creating primarily while creating BCS files, but includes a few BCD issues as well. Resolved issues are highlighted in green, all other
colours represent unresolved issues.

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Pending Issues

1. Waiting to hear back from Brian Boivin to confirm whether or not he intends to archive data from IML-2004-61 in BioChem

2. Jeff is still looking for some missing salinity data from BCD1999669, BCD2000669, and BCD2009669
