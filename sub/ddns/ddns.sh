#!/bin/sh -e

if [ -z "$DDNS_USERNAME" -o -z "$DDNS_TOKEN" -o -z "$DDNS_DOMAIN" ] ; then
  echo "required environment: DDNS_USERNAME DDNS_TOKEN DDNS_DOMAIN; skipping dynamic dns"
  exit 0
fi

export DDNS_HOSTNAME=`curl --silent http://169.254.169.254/latest/meta-data/hostname | cut -f1 -d.`

### workaround for flaky resolvers
### remove when this (or at least a switch for this) is built into base image
apt-get install bind9
echo "nameserver 127.0.0.1" > /etc/resolv.conf
echo "supersede domain-name-servers 127.0.0.1;" >> /etc/dhcp/dhclient.conf
###

ddns=/etc/cron.hourly/ddns

../../render.py < ddns > $ddns

chmod 755 $ddns

$ddns

for init in ddns ; do
    install $init.init /etc/init.d/$init
    update-rc.d $init defaults
done

# wait until the DNS catches up ...

./wait.py
