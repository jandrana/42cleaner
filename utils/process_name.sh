#!/bin/bash

# Default Directory path (if not given one as argument)
directory="~/.config/Code/"

# Check if a path is passed as an argument
if [ $# -gt 0 ]; then
    directory="$1"
fi

# Iterate over all PIDs in /proc
for pid in $(ls /proc | grep -E '^[0-9]+$'); do
    # Check if any file descriptor of the process points to the specified directory
    if ls /proc/$pid/fd 2>/dev/null | xargs -I {} readlink -f /proc/$pid/fd/{} 2>/dev/null | grep -q "$directory"; then
        # Get the command name of the process
        cmd=$(ps -p $pid -o comm=)
        # Print the PID and command name
        echo "$pid $cmd"
    fi
done
