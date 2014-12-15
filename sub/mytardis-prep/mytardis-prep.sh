#!/bin/sh -e

fs=data/mytardis
top=/$fs

zfs create $fs
chown ubuntu:ubuntu $top

for script in install.sh mytardis-create-superuser ; do
  install -o ubuntu -g ubuntu $script $top
done

echo "su -l ubuntu -c $top/install.sh < /dev/null > $top/install.log 2>&1 &" >> /etc/rc.local
