#!/bin/sh

export HOST=`hostname` HOSTNAME=`hostname`

top=/data/mytardis

cd $top/mytardis

nohup bin/gunicorn -c gunicorn_settings.py mytardis_wsgi --bind 127.0.0.1:8080 &

while [ ! `curl --silent --head localhost:9200 | grep --count '200 OK'` -eq 1 ] ; do
    echo "$HOSTNAME: waiting for elasticsearch ..." | slack
    sleep 5
done

bin/django rebuild_index --noinput

(echo "$HOSTNAME: oagr deployed" ; tail -20 $top/boot.log | sed 's/^/> /') | slack
