#!/bin/sh -e

version=v0.2

curl --silent --location https://github.com/eResearchSA/nectar-shell/archive/$version.tar.gz | tar xzvf -

cd nectar-shell-$version

./setup.sh

# should not reach this point

/sbin/poweroff
