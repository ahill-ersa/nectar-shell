#!/bin/sh -e

if [ -z "$SLACK_WEBHOOK" ] ; then
  echo "required environment: SLACK_WEBHOOK; skipping slack integration"
  exit 0
fi

slack=/usr/local/bin/slack

cat > $slack << EOF
#!/bin/sh

curl -X POST -d payload='{ "text" : "\$@" }' $SLACK_WEBHOOK
EOF

chmod 755 $slack

$slack 'initialising '`hostname` || true

slackinit=/etc/init.d/slack

cat > $slackinit << EOF
#!/bin/sh

$slack entering run-level \$RUNLEVEL: `hostname`
EOF

chmod 755 $slackinit

for runlevel in 0 3 6 ; do
  ln -s $slackinit /etc/rc$runlevel.d/S99slack
done
