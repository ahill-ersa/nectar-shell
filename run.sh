#!/bin/sh

version=v0.2.10

curl --silent --location https://github.com/eResearchSA/nectar-shell/archive/$version.tar.gz | tar xzvf -

cd nectar-shell-*

./setup.sh

# should not reach this point

/sbin/poweroff
