#!/usr/bin/env python

import json, sys

env = json.loads(sys.stdin.read())

for var in env:
    print "export %s='%s'" % (var, env[var])
