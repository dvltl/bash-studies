#!/bin/bash

#Just a template for future bash scripts

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

echo "just a template"
