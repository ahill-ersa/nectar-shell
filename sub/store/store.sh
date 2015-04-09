#!/bin/bash -e

top=/data/mytardis

#only for checking
echo $RESTORE > $top/aboutbackup.txt

#wget -q -O - $MYTARDIS_SETTINGS_URL | openssl $MYTARDIS_SETTINGS_CIPHER -d -pass pass:$MYTARDIS_SETTINGS_PASS > $top/settings.py

cd $top

#Currently under development, use branch other than master
version=db_backup
curl --silent --location https://github.com/modc08/store/archive/$version.tar.gz | tar xzvf -
mv "store-$version" store
chown -R ubuntu:ubuntu store
CONFIG_URL=${MYTARDIS_SETTINGS_URL/settings.py.enc/config.yaml.enc}
wget -q -O - $CONFIG_URL | openssl $MYTARDIS_SETTINGS_CIPHER -d -pass pass:$MYTARDIS_SETTINGS_PASS > $top/store/config.yaml

cd $top/store
sudo -u ubuntu pip install -r requirements.txt -t lib
#Set up PYTHONPATH for scripts in store
echo "export PYTHONPATH=$top/store/lib" >> /home/ubuntu/.profile

##NOT FINISHED with restoring data into database

if [[ $RESTORE =~ [0-9]{8}_[0-9]{6} ]]; then
    echo "restore a version"
    #echo "$top/store/backup.py -a retrieve $RESTORE; rundbrestore" >> /etc/rc.local
    echo "su -l ubuntu -c '$top/store/backup.py -c $top/store/config.yaml -a retrieve -n $RESTORE';gunzip -c /tmp/$RESTORE > /tmp/a.sql" >> /etc/rc.local
else
    if echo $RESTORE | grep -iwq 'latest' ; then
        echo "retrieve the latest"
        #echo "$top/store/backup.py -a retrieve; rundbrestore" >> /etc/rc.local
        echo "echo resotre latest > $top/install.log &" >> /etc/rc.local
        echo "su -l ubuntu -c '$top/store/backup.py -c $top/store/config.yaml -a retrieve -n latest';gunzip -c /tmp/$RESTORE > /tmp/a.sql" >> /etc/rc.local
    else
        echo "fresh set up"
        echo "echo fresh setup > $top/install.log &" >> /etc/rc.local
    fi
fi

# cron jobs
BACKUP=${MYTARDIS_SETTINGS_URL/settings.py.enc/db_backup.sh}
wget -q $BACKUP
chown ubuntu:ubuntu db_backup.sh
chmod u+x db_backup.sh
cat > backup.jobs << EOF
30 */2  * * *   $top/store/db_backup.sh
35 */2  * * *   $top/store/backup.py -c $top/store/config.yaml -a upload
EOF
# existing job will be removed?
crontab -u ubuntu backup.jobs
# this line: if there is no job, init will bail out with existing code of 1 which is bad
#(crontab -u ubuntu -l; echo -e "30 */2  * * *   $top/store/db_backup.sh\n35 */2  * * *   $top/store/backup.py -c $top/store/config.yaml -a upload") | crontab -u ubuntu -
