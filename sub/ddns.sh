#!/bin/sh -e

if [ -z "$DDNS_USERNAME" -o -z "$DDNS_TOKEN" -o -z "$DDNS_DOMAIN" ] ; then
  echo required: DDNS_USERNAME DDNS_TOKEN DDNS_DOMAIN
  exit 1
fi

hostname=`curl --silent http://169.254.169.254/latest/meta-data/hostname | cut -f1 -d.`

ddns=/usr/local/sbin
mkdir -p $ddns

cat > $ddns/ddns-update << EOF
#!/bin/bash

curl --silent -X POST -d "" \
  --header "x-dns-username: $DDNS_USERNAME" --header "x-dns-token: $DDNS_TOKEN" \
  https://ersa-dynamic-dns.appspot.com/v1/host/$DDNS_DOMAIN/$hostname > /dev/null 2>&1

echo $hostname.$DDNS_DOMAIN > /etc/hostname
hostname --file /etc/hostname
EOF

chmod 755 $ddns/ddns-update
