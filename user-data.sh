#!/bin/sh

export DDNS_USERNAME=
export DDNS_TOKEN=
export DDNS_DOMAIN=

export SLACK_WEBHOOK=

export JAVA_URL=

export MYTARDIS_CHECKOUT=

export NGINX_PASSWORD=

version=master

curl --silent --location https://github.com/modc08/nectar-shell/raw/$version/run.sh | sh
