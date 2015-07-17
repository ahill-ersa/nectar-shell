#!/bin/bash -e

export HOST=`hostname` HOSTNAME=`hostname`

echo "$HOSTNAME: building oagr" | slack

top=/data/mytardis

cd $top

eval `./env-restore.py < env.json`

git clone git://github.com/modc08/mytardis.git

cd mytardis

git checkout {{ OAGR_MYTARDIS_CHECKOUT }}

cp $top/settings.py tardis/settings.py

if [ -n "$OAGR_QUICK_INSTALL" ]; then
    wget -q -O - $OAGR_QUICK_INSTALL | tar xJf -
else
    cp $top/buildout-dev.cfg .

    python bootstrap.py
    bin/buildout -c buildout-dev.cfg

    patch --strip 0 --directory eggs/Django-1.5.5-py2.7.egg < $top/validation.patch
fi

if [ -n "{{ OAGR_RESTORE }}" ]; then
    echo "$HOSTNAME: restoring {{ OAGR_RESTORE }}" | slack

    (echo "set role {{ OAGR_DB_USER }};" ; $top/restore.py | unxz) | psql -d {{ OAGR_DB_NAME }}
else
    echo "$HOSTNAME: fresh install" | slack

    bin/django syncdb --noinput
    bin/django migrate --no-initial-data

    $top/mytardis-create-superuser.exp {{ OAGR_USERNAME }} {{ OAGR_PASSWORD }}
    bin/django runscript set_username

    bin/django loaddata initial_data
    bin/django loaddata doi_schema
    bin/django loaddata cc_licenses
fi

bin/django collectstatic --noinput

if [ -n "$GENOMEBROWSER_RESTORE" ]; then
    echo "$HOSTNAME: restoring genome browser files" | slack
    wget -q -O - $GENOMEBROWSER_RESTORE | tar xjf - -C static
fi
