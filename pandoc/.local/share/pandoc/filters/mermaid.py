#!/usr/bin/env python

# Copyright (c) 2023, Fynn Freyer
# This work is based on the plantuml.py filter by John MacFarlane.
# All rights reserved.
# 
# This file is distributed under the BSD 3-Clause License.
# See https://github.com/jgm/pandocfilters/blob/master/LICENSE for details.
# 

"""
Mermaid filter to process code blocks with class "mermaid" into
mermaid-generated images.

Needs the ``mmdc`` command provided by `mermaid-cli
<https://github.com/mermaid-js/mermaid-cli>`_ to be in the PATH and
executable.
"""

import os
import sys

from subprocess import call
from typing import Optional

from pandocfilters import toJSONFilter, Para, Image, get_caption, get_extension

from utils import get_cache_dir, get_tmpdir_info, get_default_image_filetype


def mermaid(key: str, value: str, format: str, meta: dict) -> Optional:
    if key == "CodeBlock":
        [[ident, classes, keyvals], code] = value

        if "mermaid" in classes:
            tmp_dir, filehash = get_tmpdir_info("mermaid", code)

            filetype = get_extension(format, get_default_image_filetype(), html="svg", latex="pdf")

            cache = get_cache_dir() / "mermaid"
            cache.mkdir(parents=True, exist_ok=True)

            src = tmp_dir / f"{filehash}.mmd"
            dest = str(cache / f"{filehash}.{filetype}")

            if not os.path.isfile(dest):
                with open(src, "w") as f:
                    f.write(code)

                format_options = ["--outputFormat", filetype]
                if filetype == "pdf":
                    format_options.append("--pdfFit")

                call(["mmdc", "--input", src, "--output", dest, *format_options, "--quiet"])
                sys.stderr.write("Created image " + dest + "\n")

            caption, typef, keyvals = get_caption(keyvals)
            return Para([Image([ident, [], keyvals], caption, [dest, typef])])


if __name__ == "__main__":
    toJSONFilter(mermaid)
    # from filter_debug_utils import run_dbg_filter
    # output = run_dbg_filter(mermaid, "test.md")
    # print(output)
