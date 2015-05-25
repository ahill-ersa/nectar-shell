#!/bin/bash -e

export PATH=/usr/local/bin:$PATH

slack=/usr/local/bin/slack

../../render.py < slack > $slack

chmod a+rx $slack

install slack.init /etc/init.d/slack
update-rc.d slack defaults

echo :new: `hostname` | $slack
