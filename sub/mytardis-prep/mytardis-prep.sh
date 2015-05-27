#!/bin/bash -e

fs=data/mytardis
top=/$fs

zfs create $fs
chown ubuntu:ubuntu $top

export OAGR_SECRET_KEY=`uuidgen`
export OAGR_DB_PASSWORD=`uuidgen`
export OAGR_DOI_URL="https://$HOSTNAME"

for template in install.sh settings.py ; do
    ../../render.py < $template > $top/$template
done

chmod a+rx $top/install.sh

for script in boot.sh restore.py mytardis-create-superuser.exp ; do
  install -o ubuntu -g ubuntu $script $top
done

../../render.py < nginx.conf > /etc/nginx/sites-available/default

cp env-restore.py $top
./env-save.py > $top/env.json

cp validation.patch buildout-dev.cfg $top

su -l postgres << EOF
createuser $OAGR_DB_USER
createdb --owner $OAGR_DB_USER $OAGR_DB_NAME
echo "alter user $OAGR_DB_USER with encrypted password '$OAGR_DB_PASSWORD'" | psql
EOF

su -l ubuntu -c $top/install.sh > $top/install.log 2>&1

cat >> /etc/rc.local << EOF
service postgresql start
service elasticsearch start

su -l ubuntu -c $top/boot.sh < /dev/null > $top/boot.log 2>&1 &
EOF
