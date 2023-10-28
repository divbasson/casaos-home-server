#!/bin/bash

# Function to recursively process files and folders
process_files() {
    local path="$1"

    # Iterate over all files and directories in the current path
    for item in "$path"/*; do
        if [ -d "$item" ]; then
            # If it's a directory, recursively process its contents
            process_files "$item"
        elif [ -f "$item" ]; then
            # If it's a file, process it
            replace_ip_in_file "$item" "$new_ip"
        fi
    done
}

# Function to replace IP addresses in a file
replace_ip_in_file() {
    local file="$1"
    local new_ip="$2"

    # Use sed to replace IP addresses in the file
    sed -i "s/192\.168\.0\.[0-9]\{1,3\}/$new_ip/g" "$file"
}

# Prompt the user for the new IP address
read -p "Enter the new IP address: " new_ip

# Start processing files from the current directory
current_dir=$(pwd)
process_files "$current_dir"

echo "IP addresses in files have been replaced with $new_ip."