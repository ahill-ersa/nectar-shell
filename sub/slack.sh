#!/bin/sh -e

if [ -z "$SLACK_WEBHOOK" ] ; then
  echo "required environment: SLACK_WEBHOOK; skipping slack integration"
  exit 0
fi

slack=/usr/local/bin/slack

cat > $slack << EOF
#!/usr/bin/env python

import json, sys, requests

payload = { "text" : sys.stdin.read().strip() }

requests.post("$SLACK_WEBHOOK", data = json.dumps(payload))
EOF

chmod 755 $slack

echo initialising `hostname` | $slack

slackinit=/etc/init.d/slack

cat > $slackinit << EOF
#!/bin/sh

echo entering run-level \$RUNLEVEL: `hostname` | $slack
EOF

chmod 755 $slackinit

for runlevel in 0 3 6 ; do
  ln -s $slackinit /etc/rc$runlevel.d/S99slack
done
