#!/bin/bash

topdir="$1"

# Check if the top directory argument is provided
if [ -z "$topdir" ]; then
  echo "Error: No top directory specified."
  echo "Usage: ./compress.sh <topdir>"
  exit 1
fi

# Check if the top directory exists
if [ ! -d "$topdir" ]; then
  echo "Error: Top directory '$topdir' does not exist."
  exit 1
fi

# Iterate over subdirectories
find "$topdir" -mindepth 1 -maxdepth 1 -type d | while IFS= read -r entry; do
  # Get the directory name
  dir_name=$(basename "$entry")

  # Create the CBZ archive
  zip_file="$entry.cbz"
  zip_command="zip -r \"$zip_file\" \"$dir_name\""
  if [ -d "$entry" ] && [ ! -f "$zip_file" ]; then
    eval "$zip_command"
    if [ $? -eq 0 ]; then
      echo "Successfully created $zip_file"
    else
      echo "Error creating $zip_file"
    fi
  fi
done
