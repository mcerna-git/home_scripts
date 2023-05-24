#!/bin/bash

# Check if the required arguments are provided
if [ $# -lt 3 ]; then
  echo "Usage: $0 <text_file> <target_folder> <extension>"
  exit 1
fi

# Retrieve the command-line arguments
text_file=$1
target_folder=$2
extension=$3

# Check if the target folder exists
if [ ! -d "$target_folder" ]; then
  echo "Target folder does not exist."
  exit 1
fi

# Check if the text file is empty
if [ ! -s "$text_file" ]; then
  echo "Text file is empty."
  exit 1
fi

# Read the lines of the text file and store them in an array
IFS=$'\n' read -d '' -r -a names < "$text_file"

# Get a sorted list of files in the target folder (excluding subfolders) with the specified extension
mapfile -d $'\0' -t files < <(find "$target_folder" -maxdepth 1 -type f -name "*.$extension" -print0 | sort -z)

# Check if any files are found
if [ ${#files[@]} -eq 0 ]; then
  echo "No files found with the specified extension in the target folder."
  exit 1
fi

# Display the before/after filenames (only file names)
echo "Before:"
for ((i = 0; i < ${#files[@]}; i++)); do
  before_file="${files[i]##*/}"
  after_file="${names[i]##*/}"
  echo "$before_file -> $after_file"
done

# Prompt for user confirmation
read -rp "Do you want to proceed with renaming? (y/n): " confirmation

if [[ $confirmation =~ ^[Yy]$ ]]; then
  # Rename the files based on the corresponding lines in the text file
  counter=0
  for file in "${files[@]}"; do
    original_file="$file"
    renamed_file="$target_folder/${names[counter]}"

    if [ "$original_file" != "$renamed_file" ]; then
      mv -i "$original_file" "$renamed_file"
    fi

    ((counter++))
  done

  echo "Files renamed successfully."
else
  echo "Operation canceled."
fi
