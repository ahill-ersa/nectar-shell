#!/bin/sh -e

export DEBIAN_FRONTEND=noninteractive

for sub in packages ddns misc slack ; do
    echo -- $sub --
    sub/$sub.sh
done

/sbin/reboot

sleep 60
