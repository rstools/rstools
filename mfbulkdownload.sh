#!/bin/bash

BASE_DIR=$(dirname $0)

read FILENAME
while [ "$FILENAME" != "" ]
do
    $BASE_DIR/mfdownload.sh $FILENAME
    read FILENAME
done
