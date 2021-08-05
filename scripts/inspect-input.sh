#!/bin/bash

script_id="$$";
files=`find /proc/$script_id/fd -not -type d`;

for file in $files;
do
    echo $file && ls -l $file

    if [ -a "$file" ]; then echo $file' -a - True if file exists.'; fi
    if [ -b "$file" ]; then echo $file' -b - True if file exists and is a block special file.'; fi
    if [ -c "$file" ]; then echo $file' -c - True if file exists and is a character special file.'; fi
    if [ -d "$file" ]; then echo $file' -d - True if file exists and is a directory.'; fi
    if [ -e "$file" ]; then echo $file' -e - True if file exists.'; fi
    if [ -f "$file" ]; then echo $file' -f - True if file exists and is a regular file.'; fi
    if [ -g "$file" ]; then echo $file' -g - True if file exists and is set-group-id.'; fi
    if [ -h "$file" ]; then echo $file' -h - True if file exists and is a symbolic link.'; fi
    if [ -k "$file" ]; then echo $file' -k - True if file exists and its ‘‘sticky’’ bit is set.'; fi
    if [ -p "$file" ]; then echo $file' -p - True if file exists and is a named pipe (FIFO).'; fi
    if [ -r "$file" ]; then echo $file' -r - True if file exists and is readable.'; fi
    if [ -s "$file" ]; then echo $file' -s - True if file exists and has a size greater than zero.'; fi    
    if [ -u "$file" ]; then echo $file' -u - True if file exists and its set-user-id bit is set.'; fi
    if [ -w "$file" ]; then echo $file' -w - True if file exists and is writable.'; fi
    if [ -x "$file" ]; then echo $file' -x - True if file exists and is executable.'; fi
    if [ -O "$file" ]; then echo $file' -O - True if file exists and is owned by the effective user id.'; fi
    if [ -G "$file" ]; then echo $file' -G - True if file exists and is owned by the effective group id.'; fi
    if [ -L "$file" ]; then echo $file' -L - True if file exists and is a symbolic link.'; fi
    if [ -S "$file" ]; then echo $file' -S - True if file exists and is a socket.'; fi
    if [ -N "$file" ]; then echo $file' -N - True if file exists and has been modified since it was last read.'; fi

    echo -e "\n\n";
done
