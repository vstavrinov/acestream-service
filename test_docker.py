# coding=utf8
from urllib.request import urlopen, quote
import json
import re
import unittest

channel = 'НТВ'
m3u_re = re.compile('#EXTINF:-1,' + channel +
                    '.*\n.*/ace/manifest.m3u8\\?infohash=[0-9a-f]+')
endpoint = 'http://localhost:8000/search.m3u?'


def probe(args):
    return urlopen(endpoint + args).read().decode('utf8')


class TestQuery(unittest.TestCase):
    def test_query(self):
        args = 'query=' + quote(channel)
        self.assertIsNotNone(m3u_re.match(probe(args)))

    def test_name(self):
        args = 'name=' + quote(channel)
        self.assertIsNotNone(m3u_re.match(probe(args)))

    def test_group(self):
        args = 'query=' + quote(channel)
        args += '&group_by_channels=1'
        self.assertIsNotNone(m3u_re.match(probe(args)))

    def test_epg(self):
        args = 'query=' + quote(channel)
        args += 'name=' + quote(channel)
        args += '&show_epg=1'
        self.assertIsNotNone(re.match('#EXTINF:-1 tvg-id="[0-9]+",' + channel +
                             '.*\n.*/ace/manifest.m3u8\\?infohash=[0-9a-f]+',
                                      probe(args)))

    def test_xml(self):
        args = 'query=' + quote(channel)
        args += '&xml_epg=1'
        self.assertIsNotNone(re.search(' +<channel id="[0-9]+">\\n +<display-name lang="ru">'
                             + channel, probe(args)))

    def test_json(self):
        args = 'query=' + quote(channel)
        args += '&json=1'
        item = json.loads(probe(args), encoding='utf8')[0]
        self.assertTrue(channel in item['name'] and
                        re.match('[0-9a-f]+', item['infohash']))


if __name__ == '__main__':
    unittest.main()
