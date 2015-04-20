#!/bin/sh -e

export HOSTNAME=`hostname`

top=/data/mytardis

cd $top

git clone git://github.com/modc08/mytardis.git

cd mytardis

git checkout `cat $top/checkout.txt`

cp $top/settings.py tardis/settings.py


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

# If it exists, add tardis.apps.acad to Django INSTALLED_APPS
if [ -d tardis/apps/acad ]
then
    sed -i "s/'tastypie',/'tastypie',\n    'tardis.apps.acad',/" tardis/settings.py
fi

# Set site title and related stuff
sed -i '/^SITE_TITLE/s/None/"OAGR"\nSITE_LONGTITLE = "Online Ancient Genome Repository"/' tardis/settings.py
sed -i '/^SPONSORED_TEXT/s/None/"Developed by University Library and eRSA"/' tardis/settings.py
sed -i '/^TIME_ZONE/s/Melbourne/Adelaide/' tardis/settings.py
sed -i '/^DEFAULT_INSTITUTION/s/Monash University/Australian Centre for Ancient DNA/' tardis/settings.py

# Set up for production deployment
sed -i '/^DEBUG/s/True/False/' tardis/settings.py
sed -i '/^ALLOWED_HOSTS/s/*/.modc08.ersa.edu.au/' tardis/settings.py

# Set up database postgres
sudo apt-get -y update
sudo apt-get -y install python-psycopg2 postgresql

# may rearrange to not to duplicate if we decide to use the same password for db user
myt_password=`cat $top/password.txt`
db_name=acad_tardis
db_user=acad

sudo -u postgres createdb -E utf8 $db_name
sudo -u postgres psql -c "CREATE USER $db_user WITH ENCRYPTED PASSWORD '$myt_password'; GRANT ALL PRIVILEGES ON DATABASE $db_name TO $db_user;"

cd /data/mytardis/mytardis
# change setting with sed
sed -i '/django.db.backends./s/sqlite3/postgresql_psycopg2/' tardis/settings.py
sed -i "/'NAME': 'db.sqlite3'/s/db.sqlite3/$db_name/" tardis/settings.py
sed -i "/'USER': 'postgres'/s/'postgres'/'$db_user'/" tardis/settings.py
sed -i "/'PASSWORD': ''/s/''/'$myt_password'/" tardis/settings.py
sed -i "/'HOST': ''/s/''/'localhost'/" tardis/settings.py

cat > buildout-dev.cfg << EOF
[buildout]
extends = buildout.cfg

[django]
settings = settings
EOF

echo "building mytardis: $HOSTNAME" | slack

python bootstrap.py
#-v 1.7.0
bin/buildout -c buildout-dev.cfg
bin/django syncdb --noinput
bin/django migrate --no-initial-data

myt_username=modc08
myt_password=`cat $top/password.txt`
$top/mytardis-create-superuser $myt_username $myt_password
bin/django runscript set_username

bin/django loaddata initial_data
bin/django loaddata doi_schema
bin/django loaddata cc_licenses

patch --strip 0 --directory eggs/Django-1.5.5-py2.7.egg < $top/validation.patch

bin/django collectstatic --noinput

HOSTNAME="`hostname`" bin/gunicorn -c gunicorn_settings.py mytardis_wsgi --bind 0.0.0.0:8080 &

# build index
bin/django rebuild_index --noinput

echo "mytardis: http://$HOSTNAME / username: $myt_username / password: $myt_password / database in Postgres created" | slack
