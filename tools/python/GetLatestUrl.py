import argparse
import re
import ftplib
import time
import datetime
import urllib
import urllib.parse

def parse_args():
	parser = argparse.ArgumentParser()
	parser.add_argument('-u', '--url', help='URL to probe for a latest file')
	parser.add_argument('-r', '--regex', default='.*', help='Specify a regular expression to accept the complete URL')
	return parser.parse_args()

class FTP:
	LIST_LINE_PATTERN = re.compile(r'\d+\s+(?P<datetime>\w{3}\s+\d{2}(\s+(?P<time>\d{2}:\d{2}))?(\s+(?P<year>\d{4}))?)\s+(?P<filename>(\S+)|(\S.*\S))$')
	URL_PATTERN = re.compile(r'^(?P<scheme>ftp://)?(?P<domain>[\w\.]+)\/?(?P<path>[\/\w\.-]+)?', re.IGNORECASE)
	
	def _parse_datetime(self, match):
		datetime_components = match.groupdict()
		datetime_format = '%b %d{0} %Y'.format(' %H:%M' if datetime_components['time'] else '')
		raw_datetime = match.group('datetime')
		if not datetime_components['year']:
			raw_datetime += ' {0}'.format(datetime.date.today().year) 
		time_struct = time.strptime(raw_datetime,datetime_format)
		return time.mktime(time_struct)
	
	def _parse_list_line(self, line):
		match = FTP.LIST_LINE_PATTERN.search(line)
		if match:
			datetime = self._parse_datetime(match)
			result = match.group('filename'), datetime
			self.files.append(result)
	
	def list(self, url):
		matcher = FTP.URL_PATTERN.match(args.url)
		if not matcher:
			raise Exception('Cannot parse url ({0})'.format(args.url))
		url_components = matcher.groupdict()
		server = url_components['domain']
		path = url_components['path'] if url_components['path'] else '.'
		ftp = ftplib.FTP(server)
		try:
			ftp.login()
			ftp.cwd(path)
			self.files = []
			ftp.retrlines('LIST', callback=self._parse_list_line)
			return self.files
		finally:
			ftp.quit()
	
	def get_latest(self, url, regex):
		files = self.list(url)
		files = filter(lambda f: regex.match(f[0]), files)
		latest_file = max(files, key=lambda f: f[1])
		return latest_file[0]
	
if __name__ == '__main__':
	args = parse_args()
	regex = re.compile(args.regex, re.IGNORECASE)
	ftp = FTP()
	latest_filename = ftp.get_latest(args.url, regex)
	# latest_url = urllib.parse.urljoin(args.url, latest_filename) - does not work in container
	latest_url = '{0}{1}{2}'.format(args.url, '' if args.url.endswith('/') else '/', latest_filename)
	print(latest_url)