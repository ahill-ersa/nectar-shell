#!/bin/sh -e

if [ -z "$DDNS_USERNAME" -o -z "$DDNS_TOKEN" -o -z "$DDNS_DOMAIN" ] ; then
  echo "required environment: DDNS_USERNAME DDNS_TOKEN DDNS_DOMAIN; skipping dynamic dns"
  exit 0
fi

export DDNS_HOSTNAME=`curl --silent http://169.254.169.254/latest/meta-data/hostname | cut -f1 -d.`

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
