#!/bin/bash

sources=$1 # text file with directory download links
job_name=$2 # directory name to use for organizing downloaded files and job logs
resolution=$3 # uses filenames to pick out files with desired resolutions, all files if not provided (!!! never use with filenames that don't specify or nothing will be downloaded !!!) 
base_dl_dir="/home/PlexCollection/showTemp"
log_dir="/home/PlexCollection/downloadLogs" 

while read -r line 
do
  desiredFiles="$(lynx -listonly -nonumbers -dump $line) end" # use " end" to ensure last link is taken  

  while read -r -d ' ' nextDownload 
  do
    current_file=${nextDownload##*/} 
    if [ -z $current_file ] || [ ! -z ${current_file##*$resolution*} ] # don't set up log files and wget jobs for index files or unspecified resolutions
     then
       continue
    fi 
    
    echo $nextDownload
    log_name=$current_file.log # create log files using downloaded files' names (not full downloaded links) 
    mkdir -p $log_dir/$job_name/ # create desired log save directory if missing 
    
    wget -N -P $base_dl_dir/$job_name -o $log_dir/$job_name/$log_name $nextDownload # current download job 
    echo $current_file:$? >> $log_dir/$job_name/results # job exit codes saved to central file 
  done < <(echo $desiredFiles) # use process substitution to avoid using external file to store temporary file download links  
done < $sources 
