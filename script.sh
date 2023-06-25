#!/bin/bash

# Set the directory where the MP3 files are located
mp3_dir="/home/peteblank/Documents/pywaifu/new"

# Find the most recent MP3 file in the directory
recent_file=$(ls -t "$mp3_dir"/*.mp3 | head -1)

# Check if there is a recent MP3 file
if [[ -n "$recent_file" ]]; then
  echo "Playing: $recent_file"
  mpg123  "$recent_file"
else
  echo "No MP3 files found in the directory: $mp3_dir"
fi
