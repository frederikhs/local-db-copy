#!/bin/bash
set -e

TRIES=30
until pg_isready > /dev/null 2>&1; do
  COUNT=$(($COUNT+1))
  echo "[$COUNT/$TRIES] waiting for ready postgres"

  if [ $COUNT -eq $TRIES ]; then
    echo "giving up"
    exit 1
  fi

  sleep 1
done
