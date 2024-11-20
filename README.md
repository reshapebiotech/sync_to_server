# sync_to_server.sh

A script to synchronize a local directory with a remote directory using `rsync` and `fswatch`.

The script respects gitignore so it does not overwrite any files that are in your gitignore

## Usage

```bash
./sync_to_server.sh source_directory remote_directory [proxy_host]
```

## Prerequisites

- `rsync` must be installed.
- `fswatch` must be installed.
- A `.gitignore` file in the source directory (optional).
- A global gitignore file configured via `git config --global core.excludesfile` (optional).

## How it works

1. Checks if the correct number of arguments are supplied.
2. Sets source and destination directories from the command line arguments.
3. Ensures `rsync` and `fswatch` are installed.
4. Performs an initial sync using `rsync`.
5. Watches for changes in the source directory and synchronizes them to the remote directory.

### Proxy host

The script supports synchronizing through an intermediate proxy/jump host when direct connection to the destination server is not possible (e.g., when the destination is behind a firewall or in a private network).

To use a proxy host, add it as the third argument:

```bash
./sync_to_server.sh /path/to/source_directory user@remote:/path/to/destination_directory proxy_user@proxy_host
```

## Example

```bash
./sync_to_server.sh /path/to/source_directory user@remote:/path/to/destination_directory
```

## Adding to PATH

If you would like the script to act more like a regular command, you can add it to your PATH.
The advantage of doing this is that you can run the script from any directory without specifying the path to the script.

There are two ways of achieving this:

1. Using a symbolic link to `/usr/local/bin/`  
  `sudo ln -s /absolute/path/to/sync_to_server.sh /usr/local/bin/sync_to_server`
2. Appending the script to your PATH environment variable  
  `export PATH=$PATH:/absolute/path/to/sync_to_server`  
  (You would probably want to add the above line to your `.bashrc` or `.zshrc`)

Then you can run the script from any directory.

```bash
sync_to_server source_directory remote_directory
```

## Notes

- The script concatenates local and global `.gitignore` files to exclude specified files during synchronization.
- The synchronization is performed using `rsync` with options for verbosity, human-readable output, archive mode, and deletion of extraneous files from the destination directory.
- Changes in the source directory are detected using `fswatch`, triggering `rsync` for each change.
