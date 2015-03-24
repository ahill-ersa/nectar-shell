#!/usr/bin/env python

# Sits around waiting until the local resolver picks up a (presumably new) name.

import os
import socket
import sys
import time

def ok(name, max_wait = 10 * 60):
    start = time.time()

    while time.time() <= (start + max_wait):
        try:
            return socket.gethostbyname(name)
        except:
            print "%s does not exist yet; waiting..." % name
            time.sleep(20)

    return None

name = "%s.%s" % (os.getenv("DDNS_HOSTNAME"), os.getenv("DDNS_DOMAIN"))

if not ok(name):
    sys.exit(1)
