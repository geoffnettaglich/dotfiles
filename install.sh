#!/bin/bash

#set -e
#set -x

BASE="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"
BASH_PROFILE="$HOME/.bash_profile"
BASH_INCLUDE="[ -r $BASE/bash_profile ] && . $BASE/bash_profile"

if [[ ! -r $BASH_PROFILE || -z `grep 'bash_profile' $BASH_PROFILE` ]]; then
  echo "Updating $BASH_PROFILE"
  echo "$BASH_INCLUDE" >> $BASH_PROFILE
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
      echo -n "Creating file $FILEPATH"
      cp $RAW $FILEPATH
    fi
    echo " for source: $FILE"
  fi
done
