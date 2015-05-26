#!/bin/bash

top=/data/mytardis

cd $top

eval `./env-restore.py < env.json`

pg_dump --no-owner --no-privileges $OAGR_DB_NAME | $top/backup.py >> $top/backup.log 2>&1
