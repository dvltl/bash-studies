#!/bin/bash

#Usage: bash name_cutter.sh <object_location> <what_to_replace> <with_what>

#If the name of a file didn't contain the substring you wanted to cut
#its name wouldn't be changed 

#Still... 
#You really don't want the name of your folder to contain the 
#substring. Don't know how to change this yet.

#It's my second bash script after all...

to_cut=$2

cd $1

directory=$PWD

for file in $directory/*
do
	if [ $3 ]
	then
		mv $file ${file//$to_cut/$3}
	else
		mv $file ${file//$to_cut/""}
	fi
	directory=$PWD
done
