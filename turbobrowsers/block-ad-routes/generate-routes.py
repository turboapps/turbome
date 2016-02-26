#!/usr/bin/env python
# -*- coding: utf-8 -*-

import logging
import sys
import argparse
import codecs
import concurrent
import concurrent.futures
import socket

DATA_ENCODING = 'UTF-8'
OUTPUT_ENCODING = 'UTF-8'
ENCODING_ERROR_POLICY = 'strict'


def fix_sys_encoding():
    if sys.stdout.encoding != OUTPUT_ENCODING:
        sys.stdout = codecs.getwriter(OUTPUT_ENCODING)(sys.stdout.buffer, ENCODING_ERROR_POLICY)
    if sys.stderr.encoding != OUTPUT_ENCODING:
        sys.stderr = codecs.getwriter(OUTPUT_ENCODING)(sys.stderr.buffer, ENCODING_ERROR_POLICY)


def setup_logger(args):
    logging.basicConfig(filename=args.log_file, level=logging.DEBUG)
    root = logging.getLogger()
    log_handler = logging.StreamHandler(sys.stdout)
    root.addHandler(log_handler)


def parse_args():
    parser = argparse.ArgumentParser(description='Resolves server hostnames to IP addresses')
    parser.add_argument('--input-file', type=str, default='hosts.txt', help='List of server host names')
    parser.add_argument('--output-file', type=str, default='routes.txt', help='List if ip addresses')
    parser.add_argument('--log-file', type=str, default='log.log', help='Log file')
    parser.add_argument('--max-retry', type=str, default=2, help='Max retry')

    return parser.parse_args()


def resolve_host(host, max_retry):
    for _ in range(max_retry):
        try:
            _hostname, _alias_list, address_list = socket.gethostbyname_ex(host)
            return address_list
        except Exception as ex:
            logging.warning('Failed to resolve host [%s]', host, ex)
    return None


def resolve_hosts(hosts, pool_size):
    addresses = set()
    with concurrent.futures.ThreadPoolExecutor(max_workers=pool_size) as executor:
        future_to_address = {executor.submit(resolve_host, host, args.max_retry): host for host in hosts}
        for future in concurrent.futures.as_completed(future_to_address):
            host = future_to_address[future]
            try:
                host_addresses = future.result()
                if host_addresses:
                    for address in host_addresses:
                        addresses.add(address)
                else:
                    logging.error('Failed to resolve hostname [%s].', host)
            except Exception as ex:
                logging.error('Failed to resolve host [%s]: %s', host, ex)
    addresses_to_use = sorted(list(addresses), key=lambda record: record[0] if record else "")
    return addresses_to_use


def get_hosts(args):
    WWW_PREFIX = 'www.'
    result = []
    with open(args.input_file, 'r') as input_file:    
        for line in input_file:
            host = line.strip()
            result.append(host)
            if host.startswith(WWW_PREFIX):
                result.append(host.replace(WWW_PREFIX, ''))
            else:
                result.append(WWW_PREFIX + host)
    return result


def save(addresses, args):
    with open(args.output_file, 'w') as output_file:

        def write_line(line):
            print(line, file=output_file)

        write_line('[ip-block]')
        for address in addresses:
            write_line(address)


def run(args):
    hosts = get_hosts(args)
    addresses = resolve_hosts(hosts, 32)
    save(addresses, args)


if __name__ == '__main__':
    args = parse_args()
    setup_logger(args)

    run(args)
