#!/bin/bash

cd docker-compose

# Get a list of all folders in the current directory
folders=$(find . -maxdepth 1 -type d)

# Iterate through each folder
for folder in $folders; do
    # Ignore the current directory (.)
    if [[ "$folder" != "." ]]; then
        # Change to the folder
        cd "$folder" || exit
        
        # Run docker-compose up
        docker-compose up -d
        
        # Wait for the container to complete
        docker wait "$(docker-compose ps -q)"
        
        # Change back to the previous directory
        cd - || exit
    fi
done
