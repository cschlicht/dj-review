#!/bin/bash

# Source and destination directories
SOURCE_DIR="/Users/cschlicht/Documents/Recordings/DJ"
DEST_DIR="/Users/cschlicht/Documents/Recordings/DJ/Processed"

# Create destination directory if it doesn't exist
mkdir -p "$DEST_DIR"

# Find all MOV files and convert them to MP3
find "$SOURCE_DIR" -maxdepth 1 -name "*.mov" -print0 | while IFS= read -r -d '' file; do
    # Get the filename without extension
    filename=$(basename "$file" .mov)
    
    # Set the output path
    output="$DEST_DIR/$filename.mp3"
    
    # Check if the MP3 file already exists
    if [ -f "$output" ]; then
        echo "Skipping '$filename.mov' - MP3 already exists"
        continue
    fi
    
    echo "Converting '$filename.mov' to MP3..."
    
    # Convert using ffmpeg with -y flag to overwrite existing files
    # -nostdin prevents interactive prompts but still shows progress
    ffmpeg -nostdin -y -i "$file" -vn -acodec libmp3lame -ac 2 -ab 192k -ar 48000 "$output"
    
    if [ $? -eq 0 ]; then
        echo "Successfully converted '$filename.mov' to MP3"
    else
        echo "Error converting '$filename.mov'"
    fi
done

echo "Conversion process completed!" 