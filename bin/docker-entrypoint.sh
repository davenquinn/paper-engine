#!/bin/bash

# Add local user
# Either use the LOCAL_USER_ID if passed in at runtime or fallback to a random user ID

USER_ID=${PAPER_USER_ID:-9001}

echo "Starting paper compilation with UID : $USER_ID"
useradd --shell /bin/bash -u $USER_ID -o -c "" -m paper-user
export HOME=/home/paper-user

cd ${PAPER_DIR:-/paper}

exec /usr/local/bin/gosu paper-user "$@"