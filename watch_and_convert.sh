#!/bin/bash

# Set up logging
exec 1> >(tee -a "/Users/cschlicht/Library/Logs/djrecording.log")
exec 2> >(tee -a "/Users/cschlicht/Library/Logs/djrecording.error.log")

echo "Script started at $(date)"
echo "Current working directory: $PWD"
echo "Current user: $(whoami)"
echo "PATH: $PATH"

# Set the source and destination directories
SOURCE_DIR="/Users/cschlicht/Documents/Recordings/Process-Me"
DEST_DIR="/Users/cschlicht/Documents/Recordings/Process-Me/Processed"

echo "Watching directory: $SOURCE_DIR"
echo "Output directory: $DEST_DIR"

# Create directories if they don't exist
mkdir -p "$SOURCE_DIR"
mkdir -p "$DEST_DIR"

# Function to convert file
convert_file() {
    local input_file="$1"
    echo "Processing file: $input_file"
    
    # Get just the filename without path and extension
    local filename=$(basename "$input_file" .mp4)
    local output_file="$DEST_DIR/${filename}.mp3"
    
    echo "Converting to: $output_file"
    
    if [ -f "$output_file" ]; then
        echo "Output file already exists, skipping: $output_file"
        return
    fi
    
    # Convert the file
    /opt/homebrew/bin/ffmpeg -i "$input_file" -vn -acodec libmp3lame "$output_file" 2>&1
    
    if [ $? -eq 0 ]; then
        echo "Successfully converted: $input_file to $output_file"
    else
        echo "Error converting file: $input_file"
    fi
}

echo "Starting fswatch..."

# Watch the directory for new files
/opt/homebrew/bin/fswatch -0 "$SOURCE_DIR" | while read -d "" event
do
    echo "Event detected: $event"
    if [[ "$event" =~ \.mov$ ]]; then
        echo "mov file detected: $event"
        convert_file "$event"
    fi
done 