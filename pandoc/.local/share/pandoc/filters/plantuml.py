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
# Change 2023-12-17:
#   - extract shared functionality to separate utils module

"""
Pandoc filter to process code blocks with class "plantuml" into
plant-generated images.

Needs a ``plantuml`` command to be in the PATH and executable.
"""

import os
import sys

from shutil import which
from subprocess import call
from typing import Optional

from pandocfilters import toJSONFilter, Para, Image, get_caption, get_extension

from utils import get_cache_dir, get_tmpdir_info, get_default_image_filetype


def plantuml(key: str, value: str, format: str, meta: dict) -> Optional:
    if key == "CodeBlock":
        [[ident, classes, keyvals], code] = value

        if any(c in {"plantuml", "puml", "uml"} for c in classes):
            # add start and end directives if necessary
            if not code.startswith("@start"):
                code = f"@startuml\n{code}\n@enduml\n"

            tmp_dir, filehash = get_tmpdir_info("plantuml", code)

            # if we can convert svg, we prefer it over raster images
            filetype = get_extension(format, get_default_image_filetype(), html="svg", latex="eps")

            cache = get_cache_dir() / "plantuml"
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
