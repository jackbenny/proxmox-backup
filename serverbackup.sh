#!/bin/bash

# Jack-Benny Persson
# LX13
# Serverbackup.sh (Övning 6, labb 5)

## Variables ##
# Define some settings for the script
BackupDir="dummyfiles" # This is were Proxmos places it's backup files
TapeDev="/dev/st0" # The device for your Tape drive
ExtHDD="/dev/sdd1" # The external harddrive
MntPoint="/mnt" # Where to mount the external harddrive
ExtHDDdir="Nebula_backups" # Where to put the backup files on the ext. drive
VMs="???" # Specify which VMs to backup (??? for all VMs)

# Backup to
Where="Tape&HDD" # Tape / HDD / Tape&HDD

# Define our binaries in case we don't have a sensible environment
Ls="/bin/ls"
Tar="/bin/tar"
Sort="/usr/bin/sort"
Tail="/usr/bin/tail"
Uniq="/usr/bin/uniq"
Mount="/bin/mount"
Umount="/bin/umount"
Mt="/bin/mt"
Cp="/bin/cp"

# Get current date & time for markers etc
CurTime=`date "+%F %X ->"`

## Sanity checks ##
# We need to run as root (for mounting, write to tape etc)
if [ $EUID -ne 0 ]; then
	echo "$CurTime Missing root privileges, aborting" > /dev/stderr
	exit 2
fi

# Check out binaries
for i in $Ls $Tar $Sort $Tail $Uniq $Mount $Umount $Mt $Cp; do
	test -x $i
	if [ $? -ne 0 ]; then
		echo "$CurTime Can't execute $i, aborting!" > /dev/stderr
		exit 2
	fi
done

# Check that our tape drive is on and connected and a tape is inserted
if [ "$Where" = "Tape" ] || [ "$Where" = "Tape&HDD" ]; then
	if [ ! -b $TapeDev ]; then
		echo "$CurTime No tape device present at $TapeDev" > /dev/stderr
		exit 2
	fi
	
	${Mt} -f ${TapeDev} status | grep DR_OPEN &> /dev/null
  	if [ $? -eq 0 ]; then
		echo "$CurTime No tape in tape drive $TapeDev" > /dev/stderr
		exit 2
	fi
fi

# Check that our external harddrive is connected and mount point exist
if [ "$Where" = "HDD" ]  || [ "$Where" = "Tape&HDD" ]; then
	if [ ! -b $ExtHDD ]; then
		echo "$CurTime No external harddrive connected to $ExtHDD" \
			> /dev/stderr
		exit 2
	elif [ ! -d $MntPoint ]; then
		echo "$CurTime Mount point $MntPoint doesn't exist, aborting" \
			> /dev/stderr
		exit 2
	fi
fi


## Main ##
cd ${BackupDir} # We do this to avoid slashes etc

# Mount our external harddisk if we want to make backups to it
if [ "$Where" = "HDD" ] || [ "$Where" = "Tape&HDD" ]; then
	$Mount $ExtHDD $MntPoint
	if [ $? -ne 0 ]; then
		echo "$CurTime Couldn't mount $ExtHDD on ${MntPoint}, aborting"\
			> /dev/stderr
		exit 2
	fi

	if [ ! -d "${MntPoint}/${ExtHDDdir}" ]; then
		printf "$CurTime ${MntPoint}/${ExtHDDdir} dosen't exist" \
			> /dev/stderr
		printf ", aborting\n" > /dev/stderr
		exit 2
	fi
fi

# Get the latest Proxmox backup date
Dates=`$Ls | awk -F - '{ print $4 }'`
Latest=`echo "$Dates" | sort | uniq | tail -n1`

# Start the actual backup/copy of files
if [ "$Where" = "HDD" ] || [ "$Where" = "Tape&HDD" ]; then
	#echo "Backup to external harddrive $ExtHDD" # Uncomment for testing
	#$Ls vzdump-*-${VMs}-${Latest}*              # and debugging

	# Create a separate directory for each backup and copy the files
	$Mkdir ${MntPoint}/${ExtHDDdir}/${Latest}
	$Cp -v vzdump-*-${VMs}-${Latest}* ${MntPoint}/${ExtHDDdir}/${Latest}	

	if [ $? -ne 0 ]; then
		echo "Something went wrong with backuping up to $ExtHDD"
		exit 2
	fi

	# Cleanup (unmount drive)
	$Umount $ExtHDD
	if [ $? -ne 0 ]; then
		echo "Couln't unmount $ExtHDD, please do it manually" \
			> /dev/stderr
	fi
fi

if [ "$Where" = "Tape" ] || [ "$Where" = "Tape&HDD" ]; then
	#echo "Backup to tape drive $TapeDev"      # Uncomment for testing
	#$Ls vzdump-*-${VMs}-${Latest}*            # and debugging
	tar cvf $TapeDev vzdump-*-${VMs}-${Latest}*

	if [ $? -ne 0 ]; then
		echo "Something went wrong when backing up to tape drive" \
			> /dev/stderr
	fi
fi

exit 0
