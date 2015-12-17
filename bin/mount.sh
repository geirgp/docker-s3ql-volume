#!/bin/bash

# un-official strict mode
set -euo pipefail

_term() {
  echo "Final Sync of files"
  /usr/local/bin/unison sync
  echo "Unmounting filesystem..."
  /usr/bin/umount.s3ql /mnt/s3ql/data > /dev/stdout 2>&1
  exit
}

trap _term SIGTERM SIGKILL

: ${FS_PASSPHRASE:=""}
: ${STORAGE_PATH:=""}

if [[   ${BACKEND_LOGIN} = "" || ${BACKEND_PASSWORD} = "" || ${STORAGE_URL} = "" ]] ; then
  echo "STORAGE_URL, BACKEND_LOGIN, and BACKEND_PASSWORD environment variables MUST be set"
  exit 1
elif [ ! -e /mnt/s3ql/authinfo2 ]; then
  echo "[s3c]" > /mnt/s3ql/authinfo2
  echo "storage-url:$STORAGE_URL" >> /mnt/s3ql/authinfo2
  echo "backend-login:$BACKEND_LOGIN" >> /mnt/s3ql/authinfo2
  echo "backend-password:$BACKEND_PASSWORD" >> /mnt/s3ql/authinfo2
  echo "fs-passphrase:$FS_PASSPHRASE" >> /mnt/s3ql/authinfo2
  chmod 600 /mnt/s3ql/authinfo2
fi

if [[ ${AUTHORIZED_SYNC_KEY} != "" ]] ; then
  echo "$AUTHORIZED_SYNC_KEY" | tee -a /root/.ssh/authorized_keys
fi

S3QL_URL=$STORAGE_URL$STORAGE_PATH

if [[ "$1" == mount.s3ql* ]]; then
  echo "mounting drive..."
  /usr/sbin/sshd
  /usr/bin/fsck.s3ql \
    --cachedir=/mnt/s3ql/cache \
    --authfile=/mnt/s3ql/authinfo2 \
    --batch \
    --log=none \
    --backend-options=dumb-copy $S3QL_URL && \
    /usr/bin/s3ql_verify \
      --cachedir=/mnt/s3ql/cache \
      --authfile=/mnt/s3ql/authinfo2 \
      --backend-options=dumb-copy $S3QL_URL && \
      /usr/bin/mount.s3ql \
        --cachedir=/mnt/s3ql/cache \
        --authfile=/mnt/s3ql/authinfo2 \
        --backend-options=dumb-copy $S3QL_URL /mnt/s3ql/data &
  /usr/local/bin/sync.sh &
  wait
elif [[ "$1" == fsck.s3ql* ]]; then
  /usr/bin/fsck.s3ql \
    --cachedir=/mnt/s3ql/cache \
    --authfile=/mnt/s3ql/authinfo2 \
    --log=none \
    --backend-options=dumb-copy $S3QL_URL
else
  exit 1
fi
