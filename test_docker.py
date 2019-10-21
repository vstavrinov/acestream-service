# coding=utf8
import sys
import query_cases
if sys.version_info[0] > 2:
    from urllib.request import urlopen
else:
    from urllib import urlopen

endpoint = 'http://localhost:8000/search.m3u8?'


class TestQuery(query_cases.TestCases):
    def probe(self, args):
        return query_cases.u_code(urlopen(endpoint + args).read().decode('utf8'))
