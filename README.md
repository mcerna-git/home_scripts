# batch_create_cbz.sh
Requirements:
- zip

Takes 1 parameter
- **topdir** (string | mandatory)

For each folder found in that directory the script will compress them as zip with .cbz extension
# batch_encode_av1.sh
Requirements:
- ffmpeg with libsvtav1 and libopus enabled
- bc

Takes 4 parameters
- **input_folder** (string | mandatory)
- **audio** (boolean | optional | default false): if true transcodes audio to opus or aac depending on the number of channels
- **resolution** (integer | optional | default 0): if enabled applies a bicubic scaling filter based on the height resolution
- **sharpen** (boolean | optional | default false): if true applies a luma sharpen filter of 5/5/1.25

The script converts all mkv and mp4 files found in the **input_folder**
For cleaning purpose titles of video and audio tracks are emptied, the file itself takes the input file name

# batch_rename_files.sh
Requirements: none

Takes 3 parameters
- **text_file** (string | mandatory)
- **target_folder** (string | mandatory)
- **extension** (string | mandatory)

The script reads the content of **text_file** and then renames files contained in **target_folder** matching **extension** with each line of text_file
- file1 renamed to line1, file2 renamed to line2 and so on

# batch_clean_mkv.sh
Requirements:
- MKVToolNix
- jq

Takes 4 parameters
- **input_folder** (string | mandatory)
- **sub_lng** (string | mandatory): language of the subtitle track to keep
- **audio_lng** (string | mandatory): language of the audio track to keep
- **audio_channels** (integer | optional | default 0): number of channel of the audio track to keep, combines with **audio_lng**

The script looks for mkv files inside the 1st level of **input_folder**
It keeps the video track, the audio track matching the parameters **audio_lng** and **audio_channels** is set, the subtitle track matching **sub_lng**
The generated files go into a subfolder "cleaned"

# write_livecd.sh
Requirements: none

Takes 3 parameters
- **usb_disk** (string | mandatory): uUSBsb device to write the LiveCD to, example /dev/sde
- **iso_path** (string | mandatory): path to the iso to write

Very simple script, to create LiveCD USB stick using dd command line
SHA256 of the iso file is displayed before asking for the user confirmation to write it to USB