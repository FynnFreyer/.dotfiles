#!/usr/bin/env python

# Copyright (c) 2013, John MacFarlane
# All rights reserved.
# 
# This file is distributed under the BSD 3-Clause License.
# See https://github.com/jgm/pandocfilters/blob/master/LICENSE for details.
# 
# Minor changes by Fynn Freyer.
# Change 2023-10-01:
#   - try to use meta to determine output dirs
#   - use `plantuml` executable, instead of jar in cwd
#   - prefer svg by default if converter is present
#   - register more classes for plantuml code

"""
Pandoc filter to process code blocks with class "plantuml" into
plant-generated images.

Needs `plantuml` to be in PATH and executable.
"""

import os
import sys

from pathlib import Path
from platform import system
from shutil import which
from subprocess import call
from typing import Optional, Tuple

from pandocfilters import toJSONFilter, Para, Image, get_filename4code, get_caption, get_extension


def get_cache_dir() -> Path:
    """Get a cache directory on Unix and Windows systems."""
    if system() == "Windows":
        data = os.environ["LOCALAPPDATA"]
    else:
        data = os.getenv("XDG_CACHE_HOME", Path.home() / ".cache")
    return Path(data).resolve()


def get_tmpdir_info(code: str) -> Tuple[Path, str]:
    """
    Get information on where to put a temporary plantuml file.

    :param code: The contents of a code block.
    :return: A tuple of (tmp_dir, content_hash).
    """
    # force get_filename4code to clean up after itself
    with open(os.devnull, "w") as devnull:
        err_tmp = sys.stderr
        try:
            os.environ["PANDOCFILTER_CLEANUP"] = "y"
            sys.stderr = devnull
            tmp_file_data = get_filename4code("plantuml", code)
        finally:
            del os.environ["PANDOCFILTER_CLEANUP"]
            sys.stderr = err_tmp

    tmp_file_base = Path(tmp_file_data)
    tmp_dir = tmp_file_base.parent
    filehash = tmp_file_base.name

    return tmp_dir, filehash


def plantuml(key: str, value: str, format: str, meta: dict) -> Optional:
    if key == "CodeBlock":
        [[ident, classes, keyvals], code] = value

        if any(c in {"plantuml", "puml", "uml"} for c in classes):
            # add start and end directives if necessary
            if not code.startswith("@start"):
                code = f"@startuml\n{code}\n@enduml\n"

            tmp_dir, filehash = get_tmpdir_info(code)

            # if we can convert svg, we prefer it over raster images
            svg_converter = which("rsvg-convert")
            default = "svg" if svg_converter else "png"
            filetype = get_extension(format, default, html="svg", latex="eps")

            cache = get_cache_dir() / "pandoc/plantuml"
            cache.mkdir(parents=True, exist_ok=True)

            src = tmp_dir / f"{filehash}.uml"
            dest = str(cache / f"{filehash}.{filetype}")

            if not os.path.isfile(dest):
                with open(src, "w") as f:
                    f.write(code)

                call(["plantuml", f"-t{filetype}", "-output", cache, src])
                sys.stderr.write("Created image " + dest + "\n")

            caption, typef, keyvals = get_caption(keyvals)
            return Para([Image([ident, [], keyvals], caption, [dest, typef])])


if __name__ == "__main__":
    toJSONFilter(plantuml)
    # from filter_debug_utils import run_dbg_filter
    # output = run_dbg_filter(plantuml, "test.md")
    # print(output)
