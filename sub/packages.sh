#!/bin/sh -e

# mirrors

cat > /etc/apt/sources.list << EOF
deb http://mirror.aarnet.edu.au/ubuntu/ trusty main universe
deb http://mirror.aarnet.edu.au/ubuntu/ trusty-updates main universe

deb http://security.ubuntu.com/ubuntu trusty-security main universe
EOF

# java

echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
add-apt-repository -y ppa:webupd8team/java

# misc

apt-get update
apt-get -y dist-upgrade
apt-get -y install build-essential clang git ifstat language-pack-en lftp libssl-dev libxml2-dev libxslt1-dev lzop mosh ntp oracle-java8-installer parallel pigz pixz pv python-dev python-pip socat software-properties-common stow supervisor sysstat tcsh traceroute unzip zip zsh

# python

pip install --upgrade python-novaclient python-keystoneclient python-glanceclient python-swiftclient

# ntp

cat > /etc/ntp.conf << EOF
driftfile /var/lib/ntp/ntp.drift
statistics loopstats peerstats clockstats
filegen loopstats file loopstats type day enable
filegen peerstats file peerstats type day enable
filegen clockstats file clockstats type day enable

server ntp.adelaide.edu.au
server time.uwa.edu.au
server ntp.uq.edu.au

restrict -4 default kod notrap nomodify nopeer noquery
restrict -6 default kod notrap nomodify nopeer noquery
restrict 127.0.0.1
restrict ::1
EOF
