#!/bin/sh -e

export HOSTNAME=`hostname`

top=/data/mytardis

cd $top

git clone git://github.com/modc08/mytardis.git

cd mytardis

git checkout `cat $top/checkout.txt`

sed -e "s/DEBUG = False/DEBUG = True/" \
    -e "s/Melbourne/Adelaide/" \
    < tardis/settings_changeme.py > tardis/settings.py

cat > buildout-dev.cfg << EOF
[buildout]
extends = buildout.cfg

[django]
settings = settings
EOF

echo "building mytardis: $HOSTNAME" | slack

python bootstrap.py -v 1.7.0
bin/buildout -c buildout-dev.cfg
bin/django syncdb --noinput --migrate

bin/django schemamigration tardis_portal --auto || true
bin/django migrate tardis_portal || true

myt_username=modc08
myt_password=`python -c 'import random, string; print str.join("", [random.sample(string.lowercase + string.digits, 1)[0] for _ in range(8)])'`
$top/mytardis-create-superuser $myt_username $myt_password

bin/django runserver 0.0.0.0:8080 < /dev/null > django.out 2>&1 &

echo "mytardis: http://$HOSTNAME:8080 / username: $myt_username / password: $myt_password" | slack
