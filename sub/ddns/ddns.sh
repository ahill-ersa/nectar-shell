#!/bin/sh -e

if [ -z "$DDNS_USERNAME" -o -z "$DDNS_TOKEN" -o -z "$DDNS_DOMAIN" ] ; then
  echo "required environment: DDNS_USERNAME DDNS_TOKEN DDNS_DOMAIN; skipping dynamic dns"
  exit 0
fi

DDNS_HOSTNAME=`curl --silent http://169.254.169.254/latest/meta-data/hostname | cut -f1 -d.`

ddns=/etc/cron.hourly/ddns

sed -e s/DDNS_USERNAME/$DDNS_USERNAME/g \
    -e s/DDNS_TOKEN/$DDNS_TOKEN/g \
    -e s/DDNS_DOMAIN/$DDNS_DOMAIN/g \
    -e s/DDNS_HOSTNAME/$DDNS_HOSTNAME/g \
    < ddns.template > $ddns

chmod 755 $ddns

$ddns

for init in ddns ; do
    install $init.init /etc/init.d/$init
    update-rc.d $init defaults
done
