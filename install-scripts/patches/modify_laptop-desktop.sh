#!/bin/bash

# Copy all .desktop files from the current directory to /usr/share/applications
for file in *.desktop; do
    if [ -f "$file" ]; then
        echo "Copying $file to /usr/share/applications"
        sudo cp -r "$file" /usr/share/applications/
    fi
done

