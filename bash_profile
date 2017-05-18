BASE="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"
PROFILES=`find $BASE/profile.d/*`
for FILE in $PROFILES ; do
  echo "Sourcing $FILE"
  . $FILE
done
