#!/bin/bash

# Copy starting apps to system folder
sudo mkdir /var/lib/casaos/apps/
sudo cp -r docker-compose/* /var/lib/casaos/apps/
sudo chmod -R 755 /var/lib/casaos/apps
cd /var/lib/casaos/apps

# Get a list of all folders in the current directory
folders=$(find . -maxdepth 1 -type d)

# Iterate through each folder
for folder in $folders; do
    # Ignore the current directory (.)
    if [[ "$folder" != "." ]]; then
        # Change to the folder
        cd "$folder" || exit
        
        # Run app install via cli
        casaos-cli app-management install -f docker-compose.yml --root-url localhost:80 && wait 5
        # Wait for the container to complete
        sudo docker ps -a
        
        # Change back to the previous directory
        cd - || exit
    fi
done
#List running containers and their IPs
sudo docker ps -q | xargs -n 1 sudo docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}} {{ .Name }}' | sed 's/ \// /'
