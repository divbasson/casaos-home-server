#!/bin/bash

# Function to search for IP addresses in a file and print them
search_ip_in_file() {
    local file="$1"
    
    # Use grep to search for the pattern in the file and print the matching lines
    grep -oE '192\.168\.0\.[0-9]{1,3}' "$file"
}

# Find all files in the current directory and its subdirectories
find . -type f -print0 | while IFS= read -r -d $'\0' file; do
    echo "Searching in $file:"
    search_ip_in_file "$file"
    echo "--------------------------------------"
done
