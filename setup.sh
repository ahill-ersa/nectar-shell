#!/bin/sh -e

export DEBIAN_FRONTEND=noninteractive

export HOST=`hostname`.$DDNS_DOMAIN HOSTNAME=`hostname`.$DDNS_DOMAIN
echo $HOST > /etc/hostname
hostname --file /etc/hostname

top=$PWD
for sub in ddns misc slack postgresql nginx elasticsearch mytardis-prep store ; do
    echo -- $sub --
    cd $top/sub/$sub
    ./$sub.sh
done
cd $top

/sbin/reboot

sleep 60
