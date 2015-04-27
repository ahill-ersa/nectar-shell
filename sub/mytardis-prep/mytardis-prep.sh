#!/bin/bash -e

fs=data/mytardis
top=/$fs

zfs create $fs
chown ubuntu:ubuntu $top

#for testing, save static first
# construct our install.sh
# TODO: remove backup or even remove install.sh
installsh=install.sh
mv $installsh ${installsh}.back

../../render.py < installsh > $installsh

chmod a+rx $installsh

for script in install.sh install-wrapper.sh mytardis-create-superuser ; do
  install -o ubuntu -g ubuntu $script $top
done

cp -f nginx-default.conf /etc/nginx/sites-available/default
cp -f nginx-elasticsearch.conf /etc/nginx/sites-available/elasticsearch
ln -s /etc/nginx/sites-available/elasticsearch /etc/nginx/sites-enabled/elasticsearch
htpasswd -bc /etc/nginx/.htpasswd modc08 $NGINX_PASSWORD

echo $MYTARDIS_CHECKOUT > $top/checkout.txt
echo $MYTARDIS_PASSWORD > $top/password.txt

cp validation.patch $top

#wget -q -O - $MYTARDIS_SETTINGS_URL | openssl $MYTARDIS_SETTINGS_CIPHER -d -pass pass:$MYTARDIS_SETTINGS_PASS > $top/settings.py
#TODO: SPECIAL_SETTINGS_URL points to branch specified settings. Change back to above when all tests are done
SPECIAL_SETTINGS_URL=${MYTARDIS_SETTINGS_URL/settings.py.enc/settings_cleaning.py.enc}
wget -q -O - $SPECIAL_SETTINGS_URL | openssl $MYTARDIS_SETTINGS_CIPHER -d -pass pass:$MYTARDIS_SETTINGS_PASS > $top/settings.py

echo "su -l ubuntu -c $top/install-wrapper.sh < /dev/null 2>&1 | tee -a $top/install.log &" >> /etc/rc.local
