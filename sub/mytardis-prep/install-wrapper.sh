#!/bin/sh

export HOSTNAME=`hostname`

top=/data/mytardis

echo "commencing mytardis deployment: $HOSTNAME" | slack

cd $top
./install.sh

if [ -x dbrestore.sh ]; then
  ./dbrestore.sh
  echo "DB restore exited with code $?" | slack
fi

(echo "$HOSTNAME: mytardis installation exited with code $?" ; tail -5 install.log | sed 's/^/> /') | slack
