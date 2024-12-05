#!/bin/bash

# Example chain files for homology assessment step
FILE1_URL="https://www.dropbox.com/scl/fi/4uboym65oz5uckfjttdpl/pantro_to_homo.chain?rlkey=odur0au6xr0l8guxts0sx7v65&st=2t6z8anv&dl=0"
FILE2_URL="https://www.dropbox.com/scl/fi/6v1do097cwe8flwzf3jit/homo_to_pantro.chain?rlkey=a5x9hbqlpem21lbubwds2z5oz&st=meezav25&dl=0"

# Target directory for chain file download
TARGET_DIR="homology/data"  
cd "$TARGET_DIR"

echo "Downloading required files..."
curl -L -O "$FILE1_URL" 
curl -L -O "$FILE2_URL"
echo "Files downloaded successfully to $TARGET_DIR."
