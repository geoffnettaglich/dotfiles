#!/bin/bash

#set -e
#set -x

BASE="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"
BASH_RC="$HOME/.bashrc"
BASH_INCLUDE="[ -r $BASE/profiles ] && . $BASE/profiles"

if [[ ! -r $BASH_RC || -z `grep 'profiles' $BASH_RC` ]]; then
  echo "Updating $BASH_RC"
  echo "$BASH_INCLUDE" >> $BASH_RC
fi

RAW="$BASE/raw"
FILES=`find $RAW -type f`

echo "RAW: $RAW"

for FILE in $FILES ; do
  NAME=$(basename "$FILE")
  if [ -n "$NAME" ] ; then
    FILEPATH="$HOME/.$NAME"

    if [ -r $FILEPATH ] ; then
      echo -n "NOTE - Skipping existing file: $FILEPATH"
    else
      echo -n "Creating file $FILEPATH from $FILE" 
      #cp $FILE $FILEPATH
      ln -s $FILE $FILEPATH
    fi
    echo " for source: $FILE"
  fi
done
