#!/bin/sh -e

../../render.py < nginx.conf > /etc/nginx/nginx.conf

echo $OAGR_HTTPS_BUNDLE | sed 's/ //g' | base64 --decode | tar xJvf - -C /etc/nginx

chmod 600 /etc/nginx/oagr.key
