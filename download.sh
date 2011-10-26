#!/bin/bash

BASE_DIR=$(dirname $0)

URL=$("$BASE_DIR"/_rsresolve.js $1)

if [ "$?" -ne "0" ]; then
  echo "$URL"
  exit 1
fi

FILENAME=$("$BASE_DIR"/_extract_filename.py $URL)

wget -c -O "$FILENAME" "$URL"
