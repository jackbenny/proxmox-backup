#!/bin/bash

# Jack-Benny Persson
# LX13
# Rotate tapes

TapeFile=tape.txt
Tape=`tail -n1 $TapeFile | awk '{ print $5 }'`
HowMany=6
TimeStamp=`date "+%F %X --> "`


if [ $Tape -ge $HowMany ]; then
	Tape=0
fi

Tape=$((Tape+1))

printf "$TimeStamp Tape $Tape\n"


exit 0
