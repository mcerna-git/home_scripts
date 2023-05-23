# Check if /home/mcerna/Documents/scripts/ is already in the PATH
if ! echo "$PATH" | grep -q "/home/mcerna/scripts/"; then
    export PATH="$PATH:/home/mcerna/scripts/"
fi
