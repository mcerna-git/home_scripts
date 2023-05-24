#!/bin/bash

# Input folder
input_folder="$1"

# Optional arguments: audio (true/false), resolution, sharpen (true/false)
audio="${2:-false}"
resolution="${3:-0}"
sharpen="${4:-false}"

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

    # Get input file resolution
    resolution_info=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 "$file")
    input_width_resolution=$(echo "$resolution_info" | awk -F 'x' '{print $1 }')

    # Get audio channel count and channel layout
    channel_count=$(ffprobe -v error -select_streams a:0 -show_entries stream=channels -of default=noprint_wrappers=1:nokey=1 "$file")
    channel_layout=$(ffprobe -v error -select_streams a:0 -show_entries stream=channel_layout -of default=noprint_wrappers=1:nokey=1 "$file")

    # Set audio codec and bitrate based on channel configuration
    if [ "$channel_count" -gt 2 ]; then
        if [ "$channel_layout" = "5.1(side)" ]; then
            audio_codec="aac"
            audio_bitrate="256k"
        else
            audio_codec="libopus"
            audio_bitrate="256k"
        fi
    elif [ "$channel_count" -eq 1 ]; then
        audio_codec="libopus"
        audio_bitrate="64k"
    else
        audio_codec="libopus"
        audio_bitrate="128k" # Default bitrate for 2.0
    fi

    # Print processing information
    echo "########################################"
    echo "Processing file: $filename"
    # Check if audio transcoding is enabled
    if [ "$audio" = "true" ]; then
        echo "Channel count: $channel_count"
        echo "Channel layout: $channel_layout"
        echo "Applied audio codec: $audio_codec"
        echo "Applied audio bitrate: $audio_bitrate"
    else
        echo "Audio copied without transcoding"
    fi
    
    echo "Input width resolution: $input_width_resolution"
    if [ "$resolution" -gt 0 ]; then
        echo "Output width Resolution: $resolution"
    else
        echo "No video rescaling"
    fi

    echo "Sharpening enabled: $sharpen"

    # Generate FFmpeg command line
    if [ "$audio" = "true" ]; then
        ffmpeg_command="ffmpeg -hide_banner -loglevel quiet -stats -i \"$file\" -c:v libsvtav1 -crf 20 -preset 6 -g 240 -svtav1-params tune=0:enable-overlays=1:scd=1 $filter_options -metadata title=\"${filename%.*}\" -metadata:s:v title= -metadata:s:a title= -c:a $audio_codec -b:a $audio_bitrate"
    else
        ffmpeg_command="ffmpeg -hide_banner -loglevel quiet -stats -i \"$file\" -c:v libsvtav1 -crf 20 -preset 6 -g 240 -svtav1-params tune=0:enable-overlays=1:scd=1 $filter_options -metadata title=\"${filename%.*}\" -metadata:s:v title= -metadata:s:a title= -c:a copy"
    fi

    # Add resolution scaling if specified
    if [ "$resolution" -gt 0 ]; then
        ffmpeg_command+=" -vf scale=$resolution:-2"
    fi

    ffmpeg_command+=" \"${input_folder}/av1/$filename\""

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
    # Convert duration to float for comparison
    duration_float=$(bc -l <<< "$duration")
    if [ $(bc <<< "$duration_float < 1") -eq 1 ]; then
        echo "Finished processing file: $filename (Duration: 0m 0s)"
    else
        echo "Finished processing file: $filename (Duration: ${minutes}m ${seconds%.*}s)"
    fi

done < <(find "$input_folder" -type f \( -name "*.mkv" -o -name "*.mp4" \) -print0 | sort -z)
