#!/bin/sh -e

# apt

echo force-unsafe-io > /etc/dpkg/dpkg.cfg.d/02apt-speedup

# mirrors

sed s/VERSION/utopic/g < sources.list > /etc/apt/sources.list

# misc

apt-get update
apt-get -y install `cat packages.txt`

# openstack

pip install --upgrade python-novaclient python-keystoneclient python-glanceclient python-swiftclient

# ntp

install -o 0 -g 0 ntp.conf /etc
