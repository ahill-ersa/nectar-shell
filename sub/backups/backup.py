#!/usr/bin/env python

import base64, hashlib, os, random, sys

from datetime import datetime

from boto.s3.connection import S3Connection

now = datetime.now().isoformat().split(".")[0]

print "initialising at %s..." % now

aws_id = base64.b64encode(os.getenv("OAGR_BACKUP_ID"))
aws_secret = hashlib.md5(os.getenv("OAGR_BACKUP_SECRET")).hexdigest()
hs3 = S3Connection(aws_access_key_id=aws_id, aws_secret_access_key=aws_secret, host=os.getenv("OAGR_BACKUP_HOST"))
bucket = hs3.get_bucket(os.getenv("OAGR_BACKUP_BUCKET"))

data = sys.stdin.read()

if len(data) == 0:
    print "nothing to upload."
    sys.exit(1)

print "uploading %i bytes..." % len(data)

key = bucket.new_key(now + "_" + hex(random.randint(0, sys.maxint))[2:7])
key.set_contents_from_string(data)

print "done."
