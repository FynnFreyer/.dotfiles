#!/usr/bin/env xonsh

import argparse

from pathlib import Path
from os import getenv


def parse_args():
    parser = argparse.ArgumentParser(description='Wrapper script around the NGS_QM pipeline')

    parser.add_argument('-f', '--format', help='file format, like "epub", or "pdf"')
    parser.add_argument('-t', '--target', help='where to move files to')

    return parser.parse_args()

if __name__ == "__main__":
    target = p'$BOOKS/unsorted/' if p'$BOOKS/unsorted/'.exists() else p'~/Documents/Books/unsorted/'
    assert target.is_dir()
    for book in g`~/Downloads/*.epub`:
        mv @(book) @(target)
