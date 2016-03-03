#!/usr/bin/env python
# ! -*- coding: utf-8 -*-

import argparse
import os
import codecs
import socket
import re

DOC = """ Builds routes file basing on uBlock Origin GitHub repo: https://github.com/gorhill/uBlock """

class FilePaths:
    def __init__(self, root_path):
        self.root_path = root_path

    @property
    def easy_list(self):
        """easylist-downloads.adblockplus.org"""
        return os.path.join(self.root_path, 'assets\\thirdparties\\easylist-downloads.adblockplus.org\\easylist.txt')

    @property
    def easy_list_privacy(self):
        return os.path.join(self.root_path, 'assets\\thirdparties\\easylist-downloads.adblockplus.org\\easyprivacy.txt')

    @property
    def pgl_yoyo(self):
        """ # https://pgl.yoyo.org/as/index.php"""
        return os.path.join(self.root_path, 'assets\\thirdparties\\pgl.yoyo.org\\as\\serverlist')

    @property
    def malware_domains(self):
        """http://www.malwaredomains.com/?page_id=1508"""
        return os.path.join(self.root_path, 'assets\\thirdparties\\mirror1.malwaredomains.com\\files\\justdomains')

    @property
    def malware_domains_list(self):
        """http://www.malwaredomainlist.com"""
        return os.path.join(self.root_path, 'assets\\thirdparties\\www.malwaredomainlist.com\\hostslist\\hosts.txt')

    @property
    def ublock_privacy(self):
        return os.path.join(self.root_path, 'assets\\ublock\\privacy.txt')

    @property
    def ublock_filters(self):
        return os.path.join(self.root_path, 'assets\\ublock\\filters.txt')


def parse_args():
    parser = argparse.ArgumentParser(description=DOC)
    parser.add_argument('--repo-dir', type=str, default='c:\\s\\uBlock', help='uBlock Origin repo')
    parser.add_argument('--output-file', type=str, default='routes.txt', help='Route file')
    return parser.parse_args()


def is_ip_address(address):
    if re.search('A-Za-z', address):
        return False

    try:
        socket.inet_aton(address)
        return True
    except socket.error:
        return False


def write_routes(host_list, output_file_path):
    with open(output_file_path, 'w') as output_file:
        def write_line(line):
            print(line, file=output_file)

        write_line('[settings]')
        write_line('PreResolveHostNames=false')
        write_line('')
        write_line('[ip-block]')
        for host in host_list:
            entry = host
            if not is_ip_address(entry):
                entry = '*.' + host
            write_line(entry)


def get_host_list(file_path):
    first_column_pattern = re.compile('127\.0\.0\.1\s+')

    with open(file_path, 'r') as file:
        for line in file:
            line_to_use = line.strip()
            if line_to_use.startswith('#'):
                continue
            host = first_column_pattern.sub('', line_to_use)
            if not host:
                continue
            yield normalize_host(host)


def normalize_host(hostname):
    if hostname.startswith('www.'):
        return hostname[4:]
    return hostname


def get_easy_list_hosts(file_path):
    forbidden_charsets = {'*', '/'}

    def get_hostname(entry):
        if not entry.startswith('||') or not entry.endswith('^'):
            return None
        if set(entry) & forbidden_charsets:
            return None
        return normalize_host(entry[2:-1])

    with codecs.open(file_path, mode='r', encoding='utf-8') as file:
        for line in file:
            hostname = get_hostname(line.strip())
            if hostname:
                yield hostname


if __name__ == '__main__':
    args = parse_args()
    file_paths = FilePaths(args.repo_dir)

    hosts = []
    hosts.extend(get_easy_list_hosts(file_paths.easy_list))
    hosts.extend(get_easy_list_hosts(file_paths.easy_list_privacy))
    hosts.extend(get_easy_list_hosts(file_paths.ublock_filters))
    hosts.extend(get_easy_list_hosts(file_paths.ublock_privacy))
    hosts.extend(get_host_list(file_paths.pgl_yoyo))
    hosts.extend(get_host_list(file_paths.malware_domains))
    hosts.extend(get_host_list(file_paths.malware_domains_list))

    hosts_to_use = sorted(list(set(hosts)))
    hosts_to_use.remove('localhost')
    write_routes(hosts_to_use, args.output_file)
