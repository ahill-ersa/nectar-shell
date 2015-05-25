#!/usr/bin/env python

import os, json

dump = {}
for var in [var for var in os.environ if var.startswith("OAGR_")]:
    dump[var] = os.environ[var]

print json.dumps(dump)
