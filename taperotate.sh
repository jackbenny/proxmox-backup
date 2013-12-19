#!/bin/bash

# Jack-Benny Persson
# LX13
# Rotate tapes

TapeFile=tape.txt
HowMany=6
TimeStamp=`date "+%F %X --> "`

# Parse command line options
while getopts i:h Opt; do
	case "$Opt" in
	i) printf "$TimeStamp Tape ${OPTARG}\n" >> $TapeFile
	   exit 0
	   ;;
	h) printf " Usage: `basename $0` -i <int> -h\n"
	   printf " -i Initalize (or start over) with this tape number\n"
	   printf " -h This help screen\n"
	   exit 0
	   ;;
	*) printf "Unknown opton, see -h (help) for more information\n"
	   ;;
	esac
done

# Check if file exist
if [ ! -e $TapeFile ]; then
	printf "$TapeFile dosen't exist, please use the -i option to init it\n"
	exit 2
fi

Tape=`tail -n1 $TapeFile | awk '{ print $5 }'`

# Check if file contains tape data
if [[ $Tape != [0-9] ]]; then
	printf "$TapeFile dosen't seem to contain tape data\n"
	printf "Use -i <int> to initizalize tape date\n"
	printf "See help (-h) for more information\n"
	exit 2
fi

# Once we reach the latest tape, rotate
if [ $Tape -ge $HowMany ]; then
	Tape=0
fi

# Else add 1 to the tape number
Tape=$((Tape+1))

# Print it to file
printf "$TimeStamp Tape $Tape\n" >> $TapeFile


exit 0
