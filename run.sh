#!/bin/sh -e

curl --silent --location URL_TO_BE_DECIDED | tar xzvf -

cd nectar-shell

./setup.sh

# should not reach this point

/sbin/poweroff
