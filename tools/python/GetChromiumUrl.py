import sys
import re
import requests
import xml.etree.ElementTree as element_tree

MAX_ATTEMTPS = 10

def get_last_change():
	r = requests.get('http://commondatastorage.googleapis.com/chromium-browser-continuous/Win/LAST_CHANGE')
	r.raise_for_status()
	return int(r.text)

def remove_default_namespace(xml):
	return re.sub(r'\sxmlns=(\'|")[^"]+\1', '', xml, count=1)
	
def get_generation(last_change):
	r = requests.get("http://commondatastorage.googleapis.com/chromium-browser-snapshots?prefix=Win/" + str(last_change))
	r.raise_for_status()
	
	doc = remove_default_namespace(r.text)
	tree = element_tree.fromstring(doc)
	for contents in tree.findall('Contents'):
		key = contents.findtext('Key')
		if key is None:
			continue
		if key.endswith('chrome-win32.zip'):
			generation = contents.findtext('Generation')
			if generation is None:
				continue
			return generation
	return None

def get_download_url(change, generation):
	return 'https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Win%2F{0}%2Fchrome-win32.zip?generation={1}&alt=media'.format(change,generation)
	
if __name__ == '__main__':
	last_change = get_last_change()
	min_change = max(0, last_change - MAX_ATTEMTPS)
	for change in range(last_change, min_change, -1):
		generation = get_generation(change)
		if generation is not None:
			download_url = get_download_url(change, generation)
			print(download_url)
			sys.exit()
	msg = 'Chromium has not been build for last {0} changes'.format(MAX_ATTEMTPS)
	print(msg, file=sys.stderr)
	sys.exit(-1)