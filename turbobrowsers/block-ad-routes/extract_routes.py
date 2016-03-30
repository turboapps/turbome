#!/usr/bin/env python
# ! -*- coding: utf-8 -*-

import argparse
import os
import codecs
import socket
import re

DOC = """ Builds routes file. Supports ad and adult blockers """

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

    @property
    def ublock_unbreak(self):
        return os.path.join(self.root_path, 'assets\\ublock\\unbreak.txt')

    @property
    def rlwpx_free_fr_adult(self):
        """http://rlwpx.free.fr/WPFF/hosts.htm"""
        return os.path.join(self.root_path, 'rlwpx.free.fr\\Hosts.sex')


def parse_args():
    parser = argparse.ArgumentParser(description=DOC)
    parser.add_argument('--repo-dir', type=str, default='c:\\s\\uBlock', help='Repo root dir')
    parser.add_argument('--output-file', type=str, default='routes.txt', help='Route file')
    parser.add_argument('--mode', type=str, default='ad', help='Which list to build. Valid modes: ad, adult')
    return parser.parse_args()


def is_ip_address(address):
    if re.search('A-Za-z', address):
        return False

    try:
        socket.inet_aton(address)
        return True
    except socket.error:
        return False


def write_routes(host_list, output_file_path, use_wildcards):
    with open(output_file_path, 'w') as output_file:
        def write_line(line):
            print(line, file=output_file)

        write_line('[settings]')
        write_line('PreResolveHostNames=false')
        write_line('')
        write_line('[ip-block]')
        for host in host_list:
            entry = host
            if use_wildcards and not is_ip_address(entry):
                entry = '*.' + host
            write_line(entry)
            if not use_wildcards:
                write_line('www.' + host)


def get_host_list(file_path):
    first_column_pattern = re.compile('^(127\.0\.0\.1|::1)\s+')

    hosts = []
    exceptions = []
    with open(file_path, 'r') as file:
        for line in file:
            line_to_use = line.strip()
            if line_to_use.startswith('#'):
                continue
            host = first_column_pattern.sub('', line_to_use)
            if not host:
                continue
            hosts.append(normalize_host(host))
    return (hosts, exceptions)


def normalize_host(hostname):
    if hostname.startswith('www.'):
        return hostname[4:]
    return hostname


def get_easy_list_hosts(file_path):
    forbidden_charsets = {'*', '/', ':'}

    def get_hostname(entry):
        if not entry.startswith('||') or not entry.endswith('^'):
            return None
        if set(entry) & forbidden_charsets:
            return None
        return normalize_host(entry[2:-1])
    
    def get_exception_hostname(entry):
        if not entry.startswith('@@||'):
            return None
        match = re.search('[/:^]', entry)
        if not match:
            return None
        hostname = entry[4:match.start()]
        if set(hostname) & forbidden_charsets:
            return None
        return normalize_host(hostname)

    hosts = []
    exceptions = []
    with codecs.open(file_path, mode='r', encoding='utf-8') as file:
        for line in file:
            entry = line.strip()
            hostname = get_hostname(entry)
            if hostname:
                hosts.append(hostname)
            exception = get_exception_hostname(entry)
            if exception:
                exceptions.append(exception)
    return (hosts, exceptions)


if __name__ == '__main__':
    args = parse_args()
    file_paths = FilePaths(args.repo_dir)

    hosts = []
    exceptions = ['localhost']
    if args.mode == 'adult':
        (new_hosts, new_exceptions) = get_host_list(file_paths.rlwpx_free_fr_adult)
        hosts.extend(new_hosts)
        exceptions.extend(new_exceptions)
    else:
        (new_hosts, new_exceptions) = get_easy_list_hosts(file_paths.easy_list)
        hosts.extend(new_hosts)
        exceptions.extend(new_exceptions)
        (new_hosts, new_exceptions) = get_easy_list_hosts(file_paths.easy_list_privacy)
        hosts.extend(new_hosts)
        exceptions.extend(new_exceptions)
        (new_hosts, new_exceptions) = get_easy_list_hosts(file_paths.ublock_filters)
        hosts.extend(new_hosts)
        exceptions.extend(new_exceptions)
        (new_hosts, new_exceptions) = get_easy_list_hosts(file_paths.ublock_privacy)
        hosts.extend(new_hosts)
        exceptions.extend(new_exceptions)
        (new_hosts, new_exceptions) = get_easy_list_hosts(file_paths.ublock_unbreak)
        hosts.extend(new_hosts)
        exceptions.extend(new_exceptions)
        (new_hosts, new_exceptions) = get_host_list(file_paths.pgl_yoyo)
        hosts.extend(new_hosts)
        exceptions.extend(new_exceptions)
        (new_hosts, new_exceptions) = get_host_list(file_paths.malware_domains)
        hosts.extend(new_hosts)
        exceptions.extend(new_exceptions)
        (new_hosts, new_exceptions) = get_host_list(file_paths.malware_domains_list)
        hosts.extend(new_hosts)
        exceptions.extend(new_exceptions)

    hosts_to_use = sorted(list(set(hosts) - set(exceptions)))
    # The adult list is so big that we do not use wildcards. This helps with
    # performance in VM, as without the wildcards it can create a hashmap.
    # Wildcards handling is unoptimized.
    use_wildcards = args.mode not in ['adult']
    write_routes(hosts_to_use, args.output_file, use_wildcards)
