#!/bin/bash -e

if [ ! $OAGR_BACKUP == "YES" ] ; then
    exit 0
fi

top=/data/mytardis

install -o ubuntu -g ubuntu -m 755 backup.?? $top

let minute="$RANDOM % 60"

echo $minute' * * * * '$top'/backup.sh' | su -l ubuntu -c crontab
