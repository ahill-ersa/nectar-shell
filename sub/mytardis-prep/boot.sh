#!/bin/sh

export HOST=`hostname` HOSTNAME=`hostname`

top=/data/mytardis

echo "launching oagr: $HOSTNAME" | slack

cd $top/mytardis

nohup bin/gunicorn -c gunicorn_settings.py mytardis_wsgi --bind 127.0.0.1:8080 &
bin/django rebuild_index --noinput

(echo "$HOSTNAME: mytardis deployed" ; tail -5 nohup.out | sed 's/^/> /') | slack
