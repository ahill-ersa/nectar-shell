#!/bin/sh -e

if [ -z "$DDNS_USERNAME" -o -z "$DDNS_TOKEN" -o -z "$DDNS_DOMAIN" ] ; then
  echo "required environment: DDNS_USERNAME DDNS_TOKEN DDNS_DOMAIN; skipping dynamic dns"
  exit 0
fi

hostname=`curl --silent http://169.254.169.254/latest/meta-data/hostname | cut -f1 -d.`

ddns=/etc/cron.hourly/ddns

cat > $ddns << EOF
#!/bin/sh

curl --silent -4 -X POST -d "" --header "x-dns-username: $DDNS_USERNAME" --header "x-dns-token: $DDNS_TOKEN" https://ersa-dynamic-dns.appspot.com/v1/host/$DDNS_DOMAIN/$hostname > /dev/null 2>&1

echo $hostname.$DDNS_DOMAIN > /etc/hostname
hostname --file /etc/hostname
EOF

chmod 755 $ddns

$ddns
