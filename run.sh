#!/bin/sh

version=master

curl --silent --location https://github.com/modc08/nectar-shell/archive/$version.tar.gz | tar xzvf -

cd nectar-shell-*

./setup.sh

# should not reach this point

/sbin/poweroff
