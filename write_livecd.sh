#!/bin/bash

usb_disk="$1"
iso_path="$2"

# Check if the ISO file exists
if [[ ! -f "$iso_path" ]]; then
    echo "ISO file does not exist: $iso_path"
    exit 1
fi

# Display SHA256 signature of the ISO file
echo "SHA256 signature of the ISO file:"
sha256sum "$iso_path"

# Ask for user confirmation before proceeding
read -p "Continue writing the ISO to the USB stick? (y/n) " choice
if [[ $choice != "y" ]]; then
    echo "Aborted."
    exit 0
fi

# Execute dd command to write the ISO to the USB stick
sudo dd bs=4M if="$iso_path" of="$usb_disk" conv=fsync oflag=direct status=progress

echo "Writing to USB stick complete."
