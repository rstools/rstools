#!/bin/bash

if [ $# -lt 1 ]
then
  echo "usage: $0 <url>"
fi

PAGEURL="$1"
BASE_DIR=`dirname "$0"`

case "$PAGEURL" in
*rapidshare*)
  FILEURL=$("$BASE_DIR"/_rsresolve.js "$1")
  if [ "$?" -ne "0" ]; then
    echo "error: $PAGEURL"
    exit 1
  fi
  FILENAME=$("$BASE_DIR"/_extract_filename.py "$FILEURL")
  wget -c -O "$FILENAME" "$FILEURL"
  ;;

*mediafire*)
  FILEURL=$("$BASE_DIR"/_mfresolve.js "$1")
  if [ "$?" -ne "0" ]; then
    echo "error: $PAGEURL"
    exit 1
  fi
  wget -c "$FILEURL"
  ;;

*)
  echo "unsupported hoster: $PAGEURL"
  exit 1
  ;;
esac
