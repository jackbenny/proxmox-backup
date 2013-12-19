# Serverbackup #
This is exercise 6 on lab 5 which is about writing a backup script for your 
server.
For this exercise I've chosen to make a backup script for Proxmox, ie take all 
the backup files (vzdump-openvz-111-2013i\_11\_19-08\_20\_20.tar.lzo and so on) 
and copy them to a tape device and an external harddrive.

## Short introduction on usage ##
At the top of the script there are several variables which you need to set
to match your system. The most important ones are __BackupDir__ which 
is where your Proxmox server places it's backup files. On my system this is 
/mnt/backup/dump (note: no trailing slash should be entered in the variables).
Then we have __TapeDev__ which is your Tape device. Most tape devices show up
as st0, st1, st2 and so on (st = SCSI Tape).
Next is the __ExtHDD__ variable which you should set to your external HDD if
you want to backup to an external harddrive. After this you set __MntPoint__
which is where you would like to mount your external harddive.
Next variable is __ExtHDDdir__ which you set to where you would like your
backup-files on your external harddrive.
A very important variable is __Where__. Here you'll define if you would place
your backup on your tape device or an external harddrive, or both. If you set
__Where__ to Tape only a tape backup will be performed. If you set it to HDD
the backup files will only to copied to your external harddrive. If you set it
to Tape&HDD your backup files will be placed on both an external harddrive and
on your tape device.

You can place your script wherever you on your system. When the script runs it
will cd into your Proxmox backups files and perform it's action from there.

All error messages are printed to STDERR and all normal messages are printed to
STDOUT. Because of this you can run this script headless and save the output
in separate logfiles depending on whatever it's an error or normal messages.
For example you can it like this:
```bash
./serverbackup.sh > backupmessages.log 2> backuperrors.log
```
