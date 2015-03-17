#!/bin/sh -e

export HOSTNAME=`hostname`

top=/data/mytardis

cd $top

git clone git://github.com/modc08/mytardis.git

cd mytardis

git checkout `cat $top/checkout.txt`

cp $top/settings.py tardis/settings.py

if grep -q 'search\|frontend\|modc08' $top/checkout.txt; then
  echo installing search engine...
  # install elasticsearch
  wget -qO - https://packages.elasticsearch.org/GPG-KEY-elasticsearch | sudo apt-key add -
  sudo add-apt-repository "deb http://packages.elasticsearch.org/elasticsearch/1.4/debian stable main"
  sudo apt-get update && sudo apt-get install elasticsearch
  sudo sh -c "echo \"script.disable_dynamic: true\" >> /etc/elasticsearch/elasticsearch.yml"
  sudo update-rc.d elasticsearch defaults 95 10
  sudo /etc/init.d/elasticsearch start
  sudo /usr/share/elasticsearch/bin/plugin -install royrusso/elasticsearch-HQ
  sudo apt-get -y install libgeos-c1

  # update settings for new haystack
  sed -i '/^SINGLE_SEARCH_ENABLED/s/False/True/' tardis/settings.py
  sed -i '/^HAYSTACK_SITECONF/s/^/# /' tardis/settings.py
  sed -i '/^HAYSTACK_SEARCH_ENGINE/s/^/# /' tardis/settings.py
  sed -i '/^HAYSTACK_SOLR_URL/s/^/# /' tardis/settings.py
  sed -i '/haystack/{n;s/^/#/;n;s/^/#/;}' tardis/settings.py
  sed -i "/HAYSTACK_ENABLE_REGISTRATIONS/aHAYSTACK_CONNECTIONS = {\n\
    'default': {\n\
        'ENGINE': 'haystack.backends.elasticsearch_backend.ElasticsearchSearchEngine',\n\
        'URL': 'http://127.0.0.1:9200/',\n\
        'INDEX_NAME': 'haystack',\n\
    },\n\
}\n\
HAYSTACK_SIGNAL_PROCESSOR = 'haystack.signals.RealtimeSignalProcessor'\n\
HAYSTACK_SEARCH_RESULTS_PER_PAGE = 40\n\
SINGLE_SEARCH_VIEW = 'tardis.apps.acad.views.single_search'\n\
NAVBAR_EXTRAS = {\n\
  'Sources': 'tardis.apps.acad.views.source_index',\n\
  'Search': 'tardis.apps.acad.views.search_source',\n\
}" tardis/settings.py
fi

# If it exists, add tardis.apps.acad to Django INSTALLED_APPS
if [ -d tardis/apps/acad ]
then
    sed -i "s/'tastypie',/'tastypie',\n    'tardis.apps.acad',/" tardis/settings.py
fi

# Set site title and related stuff
sed -i '/^SITE_TITLE/s/None/"OAGR"\nSITE_LONGTITLE = "Online Ancient Genome Repository"/' tardis/settings.py
sed -i '/^SPONSORED_TEXT/s/None/"Developed by University Library and eRSA"/' tardis/settings.py
sed -i '/^TIME_ZONE/s/Melbourne/Adelaide/' tardis/settings.py

cat > buildout-dev.cfg << EOF
[buildout]
extends = buildout.cfg

[django]
settings = settings
EOF

echo "building mytardis: $HOSTNAME" | slack

python bootstrap.py -v 1.7.0
bin/buildout -c buildout-dev.cfg
bin/django syncdb --noinput --migrate
bin/django loaddata doi_schema
bin/django loaddata cc_licenses

myt_username=modc08
myt_password=`cat $top/password.txt`
$top/mytardis-create-superuser $myt_username $myt_password
bin/django runscript set_username

HOSTNAME="`hostname`" bin/django runserver 0.0.0.0:8080 < /dev/null > django.out 2>&1 &
if grep -q 'search\|frontend\|modc08' $top/checkout.txt; then
  # build index
  bin/django rebuild_index --noinput
fi
echo "mytardis: http://$HOSTNAME / username: $myt_username / password: $myt_password" | slack
