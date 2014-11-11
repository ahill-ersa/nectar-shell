#!/bin/sh -e

# timezone

echo Australia/Adelaide > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

# rc.local

cat > /etc/rc3.d/S99misc << EOF
#!/bin/sh -e

cd /dev

for disk in vd? ; do
  echo noop > /sys/block/\$disk/queue/scheduler
done
EOF

cat > /etc/rc3.d/S99ddns << EOF
#!/bin/sh

/etc/cron.hourly/ddns
EOF

chmod +x /etc/rc3.d/S99*
