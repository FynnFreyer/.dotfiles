#!/usr/bin/env xonsh

"""
# Basic Idea
assert dnf-automatic is installed
paste sensible conf (optionally from file supplied via flag)
!(systemctl enable --now dnf-automatic.timer)
"""

import argparse
from pathlib import Path

def parse_args():
    parser = argparse.ArgumentParser(description='Set up automatic updates via DNF.')
    
    parser.add_argument('-c', '--config', type=Path,
                        help='config file for dnf-automatic, will be pasted to /etc/dnf/automatic.conf')

    
    return parser.parse_args()

if __name__ == '__main__':
    args = parse_args()
    print(args.config)

