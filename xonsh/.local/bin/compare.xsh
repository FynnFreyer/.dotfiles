#!/usr/bin/env xonsh

import argparse
import re

from pathlib import Path
from paramiko import SSHClient

def parse_args():
    args = ...
    return args

def match_sum_output(sum_output: str) -> dict[str, int]:
    # this splits a line of sum output into three groups
    regex = re.compile(r'^(\d+)\s+(\d+)\s(.+)$')
    # match[1] => hash
    # match[2] => size (?)
    # match[3] => path

    # if a line doesn't match we want to know
    # so we keep the unmatched lines for inspection
    unmatched: list[str] = []
    
    # if a hash collides we also want to know
    # so we keep a dictionary of hashes pointing
    # to a list of path strings that produced them
    collisions: dict[str, list[str]] = {}

def get_local_output(path):
    yield from (line.strip() for line in $(find @(path) -type f -exec sum '{}' ';').splitlines())


def get_remote_output(remote_host: str, remote_path):
    with SSHClient() as client:
        client.load_system_host_keys()
        client.connect(remote)
        stdin, stdout, stderr = client.exec_command(f"find {remote_path} -type f -exec sum '{{}}' ;")



