#!/bin/bash

# Input folder
input_folder="$1"

# Optional arguments: sharpen (true/false), audio (true/false)
sharpen="${2:-false}"
audio="${3:-true}"

# Create "av1" subfolder if it doesn't exist
mkdir -p "${input_folder}/av1"

# Find video files with .mkv and .mp4 extensions in the input folder
while IFS= read -r -d '' file; do
    # Extract the filename without the path
    filename=$(basename -- "$file")

    # Check if the file already exists in the "av1" subfolder
    if [[ -f "${input_folder}/av1/$filename" ]]; then
        continue
    fi

    # Set FFmpeg filter options
    filter_options=""
    if [ "$sharpen" = "true" ]; then
        filter_options="-vf unsharp=luma_msize_x=5:luma_msize_y=5:luma_amount=1.25"
    fi

    # Get audio channel count
    channel_count=$(ffprobe -v error -select_streams a:0 -show_entries stream=channels -of default=noprint_wrappers=1:nokey=1 "$file")

    # Set audio bitrate based on channel configuration
    if [ "$channel_count" -gt 2 ]; then
        audio_bitrate="256k"
    elif [ "$channel_count" -eq 1 ]; then
        audio_bitrate="64k"
    else
        audio_bitrate="128k" # Default bitrate for 2.0
    fi

    # Print processing information
    echo "########################################"
    echo "Processing file: $filename"
    echo "Sharpening enabled: $sharpen"
    echo "Audio transcoding: $audio"

    # Check if audio transcoding is enabled
    if [ "$audio" = "true" ]; then
        echo "Channel count: $channel_count"
        echo "Applied audio bitrate: $audio_bitrate"
    else
        echo "Audio copied without transcoding"
    fi

    # Generate FFmpeg command line
    if [ "$audio" = "true" ]; then
        ffmpeg_command="ffmpeg -hide_banner -loglevel quiet -stats -i \"$file\" -c:v libsvtav1 -crf 20 -preset 6 -g 240 -svtav1-params tune=0:enable-overlays=1:scd=1 $filter_options -metadata title=\"${filename%.*}\" -metadata:s:v title= -metadata:s:a title= -c:a libopus -b:a $audio_bitrate \"${input_folder}/av1/$filename\""
    else
        ffmpeg_command="ffmpeg -hide_banner -loglevel quiet -stats -i \"$file\" -c:v libsvtav1 -crf 20 -preset 6 -g 240 -svtav1-params tune=0:enable-overlays=1:scd=1 $filter_options -metadata title=\"${filename%.*}\" -metadata:s:v title= -metadata:s:a title= -c:a copy \"${input_folder}/av1/$filename\""
    fi

    echo "FFmpeg command line: $ffmpeg_command"
    echo "########################################"

    # Run FFmpeg command and measure the processing time
    start_time=$(date +%s.%N)
    eval "$ffmpeg_command" < /dev/null
    end_time=$(date +%s.%N)

    # Calculate the processing duration in seconds
    duration=$(bc <<< "$end_time - $start_time")

    # Calculate the minutes and seconds from the duration using bc
    minutes=$(bc <<< "scale=0; $duration/60")
    seconds=$(bc <<< "scale=0; $duration%60")

    # Print the completion message with the duration
    if [ "$duration" -lt 1 ]; then
        echo "Finished processing file: $filename (Duration: 0m 0s)"
    else
        echo "Finished processing file: $filename (Duration: ${minutes}m ${seconds%.*}s)"
    fi

done < <(find "$input_folder" -type f \( -name "*.mkv" -o -name "*.mp4" \) -print0 | sort -z)
