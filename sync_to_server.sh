#!/bin/bash

# Check if enough arguments are supplied
if [ "$#" -ne 2 ]; then
    echo "Usage: ./sync_to_server.sh source_directory remote_directory"
    exit 1
fi

# Set the source and destination directories from command line arguments
SRC_DIR=$1
DEST_DIR=$2

# Make sure rsync command is present
if ! [ -x "$(command -v rsync)" ]; then
  echo 'Error: rsync is not installed.' >&2
  exit 1
fi

# Make sure fswatch command is present
if ! [ -x "$(command -v fswatch)" ]; then
  echo 'Error: fswatch is not installed.' >&2
fi

# Rsync command as a function
rsync_to_server() {
  # Get list of files to be excluded
 EXCLUDE_FILES=$(mktemp)
 #  Concatenate contents of local gitignore if it exists with the global gitignore
  cat .gitignore $(git config --global core.excludesfile) > $EXCLUDE_FILES
 
  
  # echo "Excluding files: ${EXCLUDE_FILES}"

  rsync -vha  --delete --exclude .git --exclude-from=$EXCLUDE_FILES $SRC_DIR $DEST_DIR

  # Remove the temporary file
  # rm -f $EXCLUDE_FILES
}

# Initial sync
rsync_to_server

# Watch for changes and sync
fswatch -o $SRC_DIR | while read f; do
  rsync_to_server
done

