#!/bin/bash

min_size="1M"

# Prints a list of potential paths that contain >min_size cache ordered by size

find_path_with() {
	local path_with=$1
	local find_path=$(find $HOME -type d -iname "$path_with" -exec du -sh -t $min_size {} + | sort -hr)
	if [ -n "$find_path" ]; then
		printf "Paths with \"$path_with\" in name ordered by size and with minimum size=$min_size\n"
		printf "$find_path\n\n"
	else
		printf "No directories larger than $min_size found containing \"$path_with\" in name.\n\n"
	fi
}

find_path_with "cache"
find_path_with ".cache"
find_path_with "temp"