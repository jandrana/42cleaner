#!/bin/bash

min_size="1M"

# Prints a list of potential paths that contain >min_size cache ordered by size

printf "Paths with 'cache' in name ordered by size and with minimum size=$min_size\n"
find $HOME -type d -iname "cache" -print0 | xargs -0 du -ch -t $min_size | sort -hr

printf "\n\nPaths with '.cache' in name ordered by size and with minimum size=$min_size\n"
find $HOME -type d -iname ".cache" -print0 | xargs -0 du -ch -t $min_size | sort -hr

printf "\n\nPaths with 'temp' in name ordered by size and with minimum size=$min_size\n"
find $HOME -type d -iname ".cache" -print0 | xargs -0 du -ch -t $min_size | sort -hr