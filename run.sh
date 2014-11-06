#!/bin/sh

version=0.2.1

curl --silent --location https://github.com/eResearchSA/nectar-shell/archive/v$version.tar.gz | tar xzvf -

cd nectar-shell-$version

./setup.sh

# should not reach this point

/sbin/poweroff
