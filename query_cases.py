# coding=utf8
import json
import re
import sys
import unittest

# workaround for python2 vs python3 compatibility
if sys.version_info[0] > 2:
    from urllib.request import quote

    def u_code(string):
        return string
else:
    from urllib import quote

    def u_code(string):
        return string.encode('utf8')

channel = 'НТВ'
m3u_re = re.compile('#EXTM3U\n#EXTINF:-1,' + channel +
                    '.*\n.*/ace/manifest.m3u8\\?infohash=[0-9a-f]+')


class TestCases(unittest.TestCase):

    def probe(self, args):
        '''Make actual query to the service. Redefined in child class'''
        pass

    def test_query(self):
        args = 'query=' + quote(channel)
        self.assertIsNotNone(m3u_re.match(self.probe(args)))

    def test_name(self):
        args = 'query=' + quote(channel)
        args += '&name=' + quote(channel)
        self.assertIsNotNone(m3u_re.match(self.probe(args)))

    def test_group(self):
        args = 'query=' + quote(channel)
        args += '&group_by_channels=1'
        self.assertIsNotNone(m3u_re.match(self.probe(args)))

    def test_epg(self):
        args = 'query=' + quote(channel)
        args += '&name=' + quote(channel)
        args += '&show_epg=1'
        self.assertIsNotNone(re.match('#EXTM3U\n#EXTINF:-1 tvg-id="[0-9]+",' + channel +
                             '.*\n.*/ace/manifest.m3u8\\?infohash=[0-9a-f]+',
                                      self.probe(args)))

    def test_json(self):
        args = 'query=' + quote(channel)
        args += '&json=1'
        item = json.loads(self.probe(args))[0]
        self.assertTrue(channel in u_code(item['name']) and
                        re.match('[0-9a-f]+', item['infohash']))


'''
    def test_xml(self):
        args = 'query=' + quote(channel)
        args += '&xml_epg=1'
        self.assertIsNotNone(re.search(' +<channel id="[0-9]+">\\n +<display-name lang="ru">'
                             + channel, self.probe(args)))
'''
