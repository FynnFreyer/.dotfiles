#!/usr/bin/env python

# Copyright (c) 2013, John MacFarlane
# All rights reserved.
# 
# This file is distributed under the BSD 3-Clause License.
# See https://github.com/jgm/pandocfilters/blob/master/LICENSE for details.
# 
# Minor changes by Fynn Freyer.
# Change 2023-10-01:
#  - use image syntax for includes
#  - use pandoc to generate json representation based on mimetype or ending

"""
Pandoc filter to extend image syntax with transclusion. Images that don't have
a mimetype starting with ``image/`` replace their content with the included file.

This needs `pandoc` to be available in the PATH and only works with absolute links
and those relative to the current working directory.
"""

import sys

from json import loads
from mimetypes import guess_type
from subprocess import run, CalledProcessError

from pandocfilters import toJSONFilter, Div


def transclude(key: str, value: list, format: str, meta: dict):
    if key == 'Para' and len(value) == 1:
        content = value[0]
        key = content['t']
        value = content['c']
        if key == 'Image':
            _, description, [path, _] = value
            mimetype, _ = guess_type(path)
            if mimetype is not None and not mimetype.startswith('image/'):
                try:
                    # try to use the mime subtype
                    _, subtype = mimetype.split('/')
                    proc = run(['pandoc', '-f', subtype, '-t', 'json', path],
                               check=True, text=True, capture_output=True)
                except CalledProcessError as err_a:
                    # if that fails, fall back to path ending
                    try:
                        subtype = path.split('.')[-1]
                        proc = run(['pandoc', '-f', subtype, '-t', 'json', path],
                                   check=True, text=True, capture_output=True)
                    except CalledProcessError:
                        sys.stderr.write(f"{err_a.stderr}\nCouldn't compile file. This is most likely "
                                         f"due to not being in the same directory as the included file.\nSee here for "
                                         f"details: https://github.com/jgm/pandoc/issues/8492\n")
                        exit(1)
                json_data = loads(proc.stdout)
                blockdata = json_data['blocks']
                # TODO add keyvals from metadata
                # metadata = json_data['meta']
                attr = [path, ['transclusion'], []]
                return Div(attr, blockdata)


# TODO reimplement implicit figures? kinda stupid
#     if key == 'Image':
#         _, description, [path, fig_title] = value


if __name__ == "__main__":
    toJSONFilter(transclude)
    # from filter_debug_utils import run_dbg_filter
    # output = run_dbg_filter(transclude, 'test.md')
    # print(output)
