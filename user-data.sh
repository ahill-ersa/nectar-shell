#!/bin/sh

export DDNS_USERNAME=
export DDNS_TOKEN=
export DDNS_DOMAIN=

export SLACK_WEBHOOK=

export JAVA_URL=

version=master

curl --silent --location https://github.com/modc08/nectar-shell/raw/$version/run.sh | sh
