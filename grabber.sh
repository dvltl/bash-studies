#!/bin/bash

#Usage: ./grabber.sh <source_directory> <file extention> <target_folder>
#Yeah-yeah, you can do that without any scripts using 'mv' with certain parameters
#I just wanted to write something in bash

if [ $1 ]
then 
	directory=$1
	cd $directory
else
	directory=$PWD
fi

if [ $2 ]
then 
	ext=$2
else 
	exit 0
fi

if [ $3 ]
then
	dir=$3
else
	dir="ScriptFolder"
fi

if ls $directory | grep .$ext >/dev/null
then 
	mkdir $dir >/dev/null
	echo mv "$directoy/*.$ext" "$dir/"
	mv *.$ext $dir
else
	echo "No files with extention '.$ext' in $directory. Aborting."
fi

