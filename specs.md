# Specs for serverbackup #

1. Look at the files in backup directory
2. Extract the dates from the filenames
3. Check whatever a tape drive is on and contains a tape
4. Check whatever the external harddrive is connected
	* If not, try to mount it
	* If mount fails, abort script and write error log
5. Copy the latest backup to tape drive and external harddrive
6. Write everything to a logfile (script will run headless)
