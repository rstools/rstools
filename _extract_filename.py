#!/usr/bin/env python

"""
Extract the first 'filename' value from a URLs query string.
"""

import urlparse
import sys

if len(sys.argv) == 2:
    url = sys.argv[1]
    try:
        print urlparse.parse_qs(urlparse.urlparse(url).query)['filename'][0]
    except:
        print "malformed URL: " + url
else:
    print "usage: " + sys.argv[0] + " <URL>"
