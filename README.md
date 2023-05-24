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

Takes 3 parameters
- **input_folder** (string | mandatory)
- **audio** (boolean | optional | default false): if true transcodes audio to opus or aac depending on the number of channels
- **resolution** (integer | optional | default 0): if enabled applies a bicubic scaling filter
- **sharpen** (boolean | optional | default false): if true applies a luma sharpen filter of 5/5/1.25

The script converts all mkv and mp4 files found in the **input_folder**
For cleaning purpose titles of video and audio tracks are emptied, the file itself takes the input file name

# batch_rename_files.sh
Requirements none

Takes 2 parameters
- **text_file** (string | mandatory)
- **target_folder** (string | mandatory)

The script reads the content of **text_file** and then renames files contained in **target_folder** with each line of text_file
- file1 renamed to line1, file2 renamed to line2 and so on
