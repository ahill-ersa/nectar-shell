#!/bin/sh -e

# timezone

echo Australia/Adelaide > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

# init

for init in iosched ; do
    install $init.init /etc/init.d/$init
    update-rc.d $init defaults
done

# ntp

install -o 0 -g 0 ntp.conf /etc

# open the console for output

chmod a+w /dev/console

# disable IPv6

echo 'net.ipv6.conf.all.disable_ipv6=1' >> /etc/sysctl.conf
