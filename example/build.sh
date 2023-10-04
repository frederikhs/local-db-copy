#!/bin/bash
set -e

TMP_DIR=$(mktemp -d)

if [ ! -e "$TMP_DIR" ]; then
    >&2 echo "failed to create tmp directory"
    exit 1
fi

pre_exit() {
  rm -r $TMP_DIR
}

trap pre_exit EXIT

HOST=$1
USER=$2
PASS=$3

usage() {
  echo "usage: $0 <HOST> <USER> <PASS>"
  exit 1
}

if [ "$#" -ne 3 ]; then
  usage
  exit 1
fi

echo "$HOST:5432:*:$USER:$PASS" > $TMP_DIR/.pgpass

docker build \
  --secret id=pgpass,src=$TMP_DIR/.pgpass \
  -t local-db-copy-with-data \
  --no-cache \
  .
