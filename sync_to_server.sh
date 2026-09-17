#!/bin/bash

# Check if enough arguments are supplied
if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    echo "Usage: ./sync_to_server.sh source_directory remote_directory [proxy_host]"
    exit 1
fi

# Set the source and destination directories from command line arguments
SRC_DIR=$1
DEST_DIR=$2
PROXY_HOST=$3

# Make sure rsync command is present
if ! [ -x "$(command -v rsync)" ]; then
  echo 'Error: rsync is not installed.' >&2
  exit 1
fi

# Make sure fswatch command is present
if ! [ -x "$(command -v fswatch)" ]; then
  echo 'Error: fswatch is not installed.' >&2
  exit 1
fi

# Sync SRC_DIR to DEST_DIR with rsync, excluding .git and anything matched by
# a .gitignore at any depth or by the user's global git excludes file.
rsync_to_server() {
  echo -e "\n\n---\nUpdate: $(date +"%T")\n"

  # Rule order is precedence: first match wins, so repo ignores beat global ones
  FILTER_ARGS=(
    --exclude .git
    --filter=':- .gitignore'  # dir-merge: rsync reads .gitignore in every directory, patterns relative to that directory
  )
  GLOBAL_GITIGNORE=$(git config --path --global core.excludesfile 2>/dev/null)  # --path expands a leading ~
  if [ -n "$GLOBAL_GITIGNORE" ] && [ -f "$GLOBAL_GITIGNORE" ]; then
    FILTER_ARGS+=(--exclude-from="$GLOBAL_GITIGNORE")
  fi

  # --delete-after: the receiver must get updated .gitignore files before its delete pass, or it cannot protect newly ignored paths
  if [ -n "$PROXY_HOST" ]; then
      rsync -vha --delete-after "${FILTER_ARGS[@]}" -e "ssh -o ProxyCommand=\"ssh $PROXY_HOST -W %h:%p\"" $SRC_DIR $DEST_DIR
  else
      rsync -vha --delete-after "${FILTER_ARGS[@]}" $SRC_DIR $DEST_DIR
  fi
}

# Initial sync
rsync_to_server

# Watch for changes and sync
fswatch -o $SRC_DIR | while read f; do
  rsync_to_server
done

