#!/bin/bash

# Prompt user for input option
echo "Select an option:"
echo "1 = Backup casaos"
echo "2 = Restore casaos"
read -p "Enter your choice (1 or 2): " choice

if [ "$choice" == "1" ]; then
    # Execute the backup script

# Step 1: Create a TAR archive of the /DATA directory
tar -cf /tmp/DATA.tar /DATA

# Step 2: Create a TAR archive of the /var/lib/casaos/apps/ directory
tar -cf /tmp/apps.tar /var/lib/casaos/apps

# Step 3: Combine the two TAR archives into a single backup archive
backup_filename="/tmp/$(date +'%Y%m%d')-casaos-backup.tar"
tar -cf "$backup_filename" -C /tmp DATA.tar -C /tmp apps.tar

# Step 4: Delete the temporary TAR files
rm /tmp/DATA.tar
rm /tmp/apps.tar

echo "Backup created at $backup_filename"
    echo "Running backup script..."
    # Place your backup script here, e.g., from the provided backup script.
else
    if [ "$choice" == "2" ]; then
        # Execute the restore script
# Step 1: Extract the contents of the backup archive to /tmp/restore/
tar -xf casaos-backup.tar -C /tmp/restore/

# Step 2: Copy the contents of the DATA extracted folder to /DATA
if [ -d /tmp/restore/DATA ]; then
    mkdir -p /DATA
    cp -r /tmp/restore/DATA/* /DATA/
    chmod -R 755 /DATA
fi

# Step 3: Copy the contents of the apps extracted folder to /var/lib/casaos/apps/
if [ -d /tmp/restore/apps ]; then
    mkdir -p /var/lib/casaos/apps
    cp -r /tmp/restore/apps/* /var/lib/casaos/apps/
    chmod -R 755 /var/lib/casaos/apps
fi

# Step 4: Go to /var/lib/casaos/apps and run the provided script
if [ -d /var/lib/casaos/apps ]; then
    cd /var/lib/casaos/apps || exit
    
    # Get a list of all folders in the current directory
    folders=$(find . -maxdepth 1 -type d)
    
    # Iterate through each folder
    for folder in $folders; do
        # Ignore the current directory (.)
        if [[ "$folder" != "." ]]; then
            # Change to the folder
            cd "$folder" || exit
            
            # Run app install via cli
            casaos-cli app-management install -f docker-compose.yml --root-url localhost:80 && sleep 5
            
            # Wait for the container to complete
            sudo docker ps -a
            
            # Change back to the previous directory
            cd - || exit
        fi
    done

    # List running containers and their IPs
    sudo docker ps -q | xargs -n 1 sudo docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}} {{ .Name }}' | sed 's/ \// /'
fi

echo "Restoration and setup completed."
        echo "Running restore script..."
        # Place your restore script here, e.g., from the provided restore script.
    else
        echo "Invalid choice. Please enter '1' for backup or '2' for restore."
    fi
fi
