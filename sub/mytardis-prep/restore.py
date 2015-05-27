#!/usr/bin/env python

import base64, hashlib, os, sys

from boto.s3.connection import S3Connection

aws_id = base64.b64encode(os.getenv("OAGR_BACKUP_ID"))
aws_secret = hashlib.md5(os.getenv("OAGR_BACKUP_SECRET")).hexdigest()
hs3 = S3Connection(aws_access_key_id=aws_id, aws_secret_access_key=aws_secret, host=os.getenv("OAGR_BACKUP_HOST"))
bucket = hs3.get_bucket(os.getenv("OAGR_BACKUP_BUCKET"))

data = bucket.get_key(os.getenv("OAGR_RESTORE")).read()

sys.stdout.write(data)
