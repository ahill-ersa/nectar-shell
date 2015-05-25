#!/bin/bash -e

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
