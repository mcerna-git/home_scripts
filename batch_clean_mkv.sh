#!/bin/bash

# Check if the MKVToolNix suite is installed
if ! command -v mkvmerge >/dev/null 2>&1; then
  echo "MKVToolNix suite is not installed. Please install it and try again."
  exit 1
fi

# Check if jq is installed
if ! command -v jq >/dev/null 2>&1; then
  echo "jq is not installed. Please install it and try again."
  exit 1
fi

# Check if the required number of command-line arguments is provided
if [ $# -ne 3 ]; then
  echo "Insufficient arguments. Please provide the required parameters."
  echo "Usage: $0 <input_folder> <sub_lng> <audio_lng> [<audio_channels>]"
  exit 1
fi

# Assign the command-line arguments to variables
input_folder="$1"
sub_lng="$2"
audio_lng="$3"
audio_channels="${4:-0}"

# Check if the target folder exists
if [ ! -d "$input_folder" ]; then
  echo "Target folder does not exist: $input_folder"
  exit 1
fi

# Create the 'cleaned' directory if it doesn't exist
output_dir="cleaned"
mkdir -p "$output_dir"

# Process each MKV file within the target folder
for file in "$input_folder"/*.mkv; do
  # Check if the file is an MKV file
  if [ -f "$file" ]; then
    echo "Processing file: $file"

    # Use mkvmerge -J to retrieve track IDs based on provided parameters
    if [ "$audio_channels" -ne 0 ]; then
      audio_track_ids=$(mkvmerge -J "$file" | jq -r --arg audio_lng "$audio_lng" --argjson audio_channels "$audio_channels" '.tracks[] | select(.type == "audio" and .properties.language == $audio_lng and .properties.audio_channels == $audio_channels) | .id')
    else
      audio_track_ids=$(mkvmerge -J "$file" | jq -r --arg audio_lng "$audio_lng" '.tracks[] | select(.type == "audio" and .properties.language == $audio_lng) | .id')
    fi

    subtitle_track_ids=$(mkvmerge -J "$file" | jq -r --arg sub_lng "$sub_lng" '.tracks[] | select(.type == "subtitles" and .properties.language == $sub_lng) | .id')

    echo "audio_track_ids: $audio_track_ids"
    echo "subtitle_track_ids: $subtitle_track_ids"

    # Check if audio_track_ids or subtitle_track_ids are empty
    if [ -z "$audio_track_ids" ]; then
      echo "No audio track found for language: $audio_lng with number of channels: $audio_channels"
      continue
    fi

    if [ -z "$subtitle_track_ids" ]; then
      echo "No subtitle track found for language: $sub_lng"
      continue
    fi

    # Construct the mkvmerge command with the track IDs
    output_file=("$output_dir/$(basename "$file")")
    mkvmerge_command="mkvmerge -o \"$output_file\" -a $audio_track_ids -s $subtitle_track_ids \"$file\""
    
    echo $mkvmerge_command

    eval "$mkvmerge_command"

    echo "#####################"
  fi
done
