#!/bin/bash

# Add local user
# Either use the LOCAL_USER_ID if passed in at runtime or fallback to a random user ID

USER_ID=${PAPER_USER_ID:-9001}

echo "Starting paper compilation with UID : $USER_ID"
useradd --shell /bin/bash -u $USER_ID -o -c "" -m paper-user
export HOME=/home/paper-user

dir=${PAPER_DIR:-/paper}
if [ -d "$dir" ]; then
  cd "$dir"
else
  echo "Paper directory $dir does not exist, perhaps you need to mount a volume?" >&2
fi

# Set a default git user
gosu paper-user git config --global user.email "anonymous@paper"
gosu paper-user git config --global user.name "Anonymous"

# Use gosu to drop privileges and run the command
exec gosu paper-user "$@"