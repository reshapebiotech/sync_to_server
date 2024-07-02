# sync_to_server.sh

A script to synchronize a local directory with a remote directory using `rsync` and `fswatch`.

The script respects gitignore so it does not overwrite any files that are in your gitignore

## Usage

```bash
./sync_to_server.sh source_directory remote_directory
```

## Prerequisites

- `rsync` must be installed.
- `fswatch` must be installed.
- A `.gitignore` file in the source directory (optional).
- A global gitignore file configured via `git config --global core.excludesfile` (optional).

## How It Works

1. Checks if the correct number of arguments are supplied.
2. Sets source and destination directories from the command line arguments.
3. Ensures `rsync` and `fswatch` are installed.
4. Performs an initial sync using `rsync`.
5. Watches for changes in the source directory and synchronizes them to the remote directory.

## Example

```bash
./sync_to_server.sh /path/to/source_directory user@remote:/path/to/destination_directory
```

## Notes

- The script concatenates local and global `.gitignore` files to exclude specified files during synchronization.
- The synchronization is performed using `rsync` with options for verbosity, human-readable output, archive mode, and deletion of extraneous files from the destination directory.
- Changes in the source directory are detected using `fswatch`, triggering `rsync` for each change.
