#!/usr/bin/env python

import os
import sys

from jinja2 import Template

content = Template(sys.stdin.read())

print content.render(os.environ)
