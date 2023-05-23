#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Usage: $0 folder_path"
  exit 1
fi

folder_path="$1"

if [ ! -d "$folder_path" ]; then
  echo "Error: $folder_path is not a directory"
  exit 1
fi

cd "$folder_path"

for file in *; do
  if [ -f "$file" ]; then
    extension="${file##*.}"
    filename="${file%.*}"
    new_filename="$(printf "%03d.%s" "$filename" "$extension")"
    if [ "$new_filename" != "$file" ]; then
      mv "$file" "$new_filename"
      echo "Renamed $file to $new_filename"
    fi
  fi
done
