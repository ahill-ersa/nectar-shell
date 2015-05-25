#!/bin/sh -e

export HOST=`hostname` HOSTNAME=`hostname`

top=/data/mytardis

cd $top

eval `./env-restore.py < env.json`

git clone git://github.com/modc08/mytardis.git

cd mytardis

git checkout {{ OAGR_MYTARDIS_CHECKOUT }}

cp $top/settings.py tardis/settings.py

cat > buildout-dev.cfg << EOF
[buildout]
extends = buildout.cfg

[django]
settings = settings
EOF

echo "building mytardis: $HOSTNAME" | slack

python bootstrap.py
bin/buildout -c buildout-dev.cfg
bin/django syncdb --noinput
bin/django migrate --no-initial-data

$top/mytardis-create-superuser.exp {{ OAGR_USERNAME }} {{ OAGR_PASSWORD }}
bin/django runscript set_username

bin/django loaddata initial_data
bin/django loaddata doi_schema
bin/django loaddata cc_licenses

patch --strip 0 --directory eggs/Django-1.5.5-py2.7.egg < $top/validation.patch

bin/django collectstatic --noinput
