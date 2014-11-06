#!/bin/sh -e

# timezone

echo Australia/Adelaide > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

# rc.local

cat > /etc/rc.local << EOF
#!/bin/sh -e

cd /dev

for disk in vd? ; do
  echo noop > /sys/block/\$disk/queue/scheduler
done

/usr/local/sbin/ddns-update
EOF

# cron

echo '0 * * * * /usr/local/sbin/ddns-update' | crontab -u ubuntu -
