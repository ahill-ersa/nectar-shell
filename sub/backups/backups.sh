#!/bin/bash -e

top=/data/mytardis

install -o ubuntu -g ubuntu -m 755 backup.?? $top

echo '42 * * * * '$top'/backup.sh' | su -l ubuntu -c crontab
