#!/bin/bash

# Example chain files for homology assessment step
FILE1_URL="https://www.dropbox.com/scl/fi/tqnvtxb4u0dmwg5z36vbi/homo_to_pantro.chain?rlkey=g3tcrkgwe9q9qnn276i4bdwes&st=9findjgi&dl=0"
FILE2_URL="https://www.dropbox.com/scl/fi/r8v3tu9aab5zvkx3o5yuc/pantro_to_homo.chain?rlkey=ppyoe3ntmueqc64zf07jfwji7&st=zit7dpei&dl=0"

# Target directory for chain file download
TARGET_DIR="homology/data"  
cd "$TARGET_DIR"

echo "Downloading required files..."
curl -L -O "$FILE1_URL" 
curl -L -O "$FILE2_URL"
echo "Files downloaded successfully to $TARGET_DIR."
