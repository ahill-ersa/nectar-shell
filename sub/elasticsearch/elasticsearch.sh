#!/bin/bash -e

# packages

wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | apt-key add -
add-apt-repository "deb http://packages.elastic.co/elasticsearch/1.4/debian stable main"
apt-get update
apt-get -y install elasticsearch libgeos-c1

# config

cat >> /etc/elasticsearch/elasticsearch.yml << ES_EOF
script.disable_dynamic: true
network.host: 127.0.0.1
ES_EOF

update-rc.d elasticsearch defaults 95 10
service elasticsearch start

# web

/usr/share/elasticsearch/bin/plugin -install royrusso/elasticsearch-HQ

../../render.py < nginx.conf > /etc/nginx/sites-available/elasticsearch
ln -s /etc/nginx/sites-available/elasticsearch /etc/nginx/sites-enabled/elasticsearch
htpasswd -bc /etc/nginx/elasticsearch.htpasswd modc08 $OAGR_NGINX_PASSWORD

# zfs

service elasticsearch stop

fs=data/elasticsearch
zfs create $fs
chown elasticsearch:elasticsearch /$fs
mv /var/lib/elasticsearch/* /$fs
rmdir /var/lib/elasticsearch
ln -s /$fs /var/lib/elasticsearch

# done

service elasticsearch start
