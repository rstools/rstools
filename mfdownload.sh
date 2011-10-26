#!/bin/bash

BASE_DIR=$(dirname $0)

URL=$("$BASE_DIR"/_mfresolve.js $1)

if [ "$?" -ne "0" ]; then
  echo "$URL"
  exit 1
fi

wget -c "$URL"
