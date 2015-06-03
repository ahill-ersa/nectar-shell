#!/bin/bash -e

# packages

apt-get update
apt-get -y install python-psycopg2 postgresql

# ubuntu user

su -l postgres -c 'createuser --superuser ubuntu'

# zfs

service postgresql stop

fs=data/postgresql
zfs create $fs
chown postgres:postgres /$fs
mv /var/lib/postgresql/* /$fs
rmdir /var/lib/postgresql
ln -s /$fs /var/lib/postgresql

# auth

cp -f pg_hba.conf /etc/postgresql/9.4/main

# done

sysv-rc-conf postgresql off
service postgresql start
