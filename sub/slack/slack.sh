#!/bin/sh -e

if [ -z "$SLACK_WEBHOOK" ] ; then
    echo "required environment: SLACK_WEBHOOK; skipping slack integration"
    exit 0
fi

export PATH=/usr/local/bin:$PATH

slack=/usr/local/bin/slack

../../render.py < slack > $slack

chmod a+rx $slack

install slack.init /etc/init.d/slack
update-rc.d slack defaults

echo :new: `hostname` | $slack
