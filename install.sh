#!/bin/bash

set -e
set -x

DIR=$(dirname $0)



RAW="$DIR/raw/*"
FILES=`find $DIR/raw/* -type f`

for FILE in $RAW ; do
  NAME=$(basename "$FILE")
  if [ -n "$NAME" ] ; then
    FILEPATH="$HOME/.$NAME"
    if [ -r $FILEPATH ] ; then
      echo "File exists $FILEPATH"
    else
      echo "Creating file $FILEPATH"
      cp $RAW $FILEPATH
    fi
  fi
done
