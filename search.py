#!/usr/bin/env python
#
import cgi, cgitb
cgitb.enable()
from acestream_search.acestream_search import main as search, args

print("Content-Type: application/x-mpegURL\n")
opts = cgi.parse(keep_blank_values=True)
for item in opts:
    opts[item] = opts[item][0]

args.__dict__.update(opts)


if 'help' in opts:
    print(args.usage)
else:
    search()

