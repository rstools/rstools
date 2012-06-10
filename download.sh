#!/bin/bash

if [ $# -lt 1 ]
then
  echo "usage: $0 <url>"
fi

PAGEURL="$1"
BASE_DIR=`dirname "$0"`

case "$PAGEURL" in
*megaupload*)
  FILEURL=$("$BASE_DIR"/_muresolve.js "$1")
  if [ "$?" -ne "0" ]; then
    echo "error: $PAGEURL"
    exit 1
  fi
  wget -c "$FILEURL"
  ;;

*rapidshare*)
  FILEURL=$("$BASE_DIR"/_rsresolve.js "$1")
  if [ "$?" -ne "0" ]; then
    echo "error: $PAGEURL"
    exit 1
  fi
  FILENAME=$("$BASE_DIR"/_extract_filename.py "$FILEURL")
  wget --timeout=0 -c -O "$FILENAME" "$FILEURL"
  ;;

*mediafire*)
  FILEURL=$("$BASE_DIR"/_mfresolve.js "$1")
  if [ "$?" -ne "0" ]; then
    echo "error: $PAGEURL"
    exit 1
  fi
  wget -c "$FILEURL"
  ;;

*uploading*)
  "$BASE_DIR"/dluploading "$PAGEURL"
  ;;

*)
  echo "unsupported hoster: $PAGEURL"
  exit 1
  ;;
esac
