#!/bin/sh -e

export DEBIAN_FRONTEND=noninteractive

export HOST=`hostname` HOSTNAME=`hostname`

top=$PWD
for sub in ddns misc slack mytardis-prep ; do
    echo -- $sub --
    cd $top/sub/$sub
    ./$sub.sh
done
cd $top

/sbin/reboot

sleep 60
