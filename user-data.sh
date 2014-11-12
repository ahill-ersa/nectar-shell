#!/bin/sh

export DDNS_USERNAME=
export DDNS_TOKEN=
export DDNS_DOMAIN=

export SLACK_WEBHOOK=

export JAVA_URL=

#version=master
version=v0.2.9

curl --silent --location https://github.com/eResearchSA/nectar-shell/raw/$version/run.sh | sh
