#!/bin/bash

# Function to replace IP addresses in a file
replace_ip_in_file() {
    local file="$1"
    local old_ip="192.168.0."
    local new_ip="$2"

    # Use sed to replace IP addresses in the file
    sed -i "s/$old_ip[0-9]\{1,3\}/$new_ip/g" "$file"
}

# Prompt the user for the new IP address
read -p "Enter the new IP address: " new_ip

# Find all files in the current directory and its subdirectories
find . -type f -exec sh -c 'replace_ip_in_file "$0" "$1"' {} "$new_ip" \;

echo "IP addresses in files have been replaced with $new_ip."