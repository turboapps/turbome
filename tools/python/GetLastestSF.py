import argparse
import re
import ftplib
import time
import datetime
import urllib.request
import xml.etree.ElementTree as element_tree

LOCALE_REGEX = re.compile('\s\w{2}$', re.IGNORECASE)

def parse_args():
	parser = argparse.ArgumentParser()
	parser.add_argument('-u', '--url', help='URL to probe for a latest file')
	parser.add_argument('-r', '--regex', default='.*', help='Specify a regular expression to accept the complete URL')
	return parser.parse_args()

def get_files(url):
	response = urllib.request.urlopen(url)
	doc = response.read().decode('utf-8')
	tree = element_tree.fromstring(doc)
	for item in tree.iter('item'):
		title = item.find('title').text
		raw_datetime = LOCALE_REGEX.sub('', item.find('pubDate').text)
		time_struct = time.strptime(raw_datetime, '%a, %d %b %Y %H:%M:%S')
		date_time = time.mktime(time_struct)
		link = item.find('link').text
		yield (title, date_time, link)
	
def get_latest(url, regex):
	files = list(get_files(url))
	files = filter(lambda f: regex.match(f[0]), files)
	latest_file = max(files, key=lambda f: f[1])
	return latest_file[2]
	
if __name__ == '__main__':
	args = parse_args()
	regex = re.compile(args.regex, re.IGNORECASE)
	latest_url = get_latest(args.url, regex)
	print(latest_url)