import os
import sys

from pathlib import Path
from platform import system
from shutil import which
from typing import Tuple, Literal

from pandocfilters import get_filename4code


def get_cache_dir() -> Path:
    """Get a cache directory on Unix and Windows systems."""
    if system() == "Windows":
        data = os.environ["LOCALAPPDATA"]
    else:
        data = os.getenv("XDG_CACHE_HOME", Path.home() / ".cache")
    return Path(data).resolve() / "pandoc"


def get_tmpdir_info(prefix: str, code: str) -> Tuple[Path, str]:
    """
    Get information on where to put a temporary file.

    :param prefix: The module that uses this data.
    :param code: The contents of a code block.
    :return: A tuple of (tmp_dir, content_hash).
    """
    # force get_filename4code to clean up after itself
    with open(os.devnull, "w") as devnull:
        err_tmp = sys.stderr
        try:
            os.environ["PANDOCFILTER_CLEANUP"] = "y"
            sys.stderr = devnull
            tmp_file_data = get_filename4code(prefix, code)
        finally:
            del os.environ["PANDOCFILTER_CLEANUP"]
            sys.stderr = err_tmp

    tmp_file_base = Path(tmp_file_data)
    tmp_dir = tmp_file_base.parent
    filehash = tmp_file_base.name

    return tmp_dir, filehash


def get_default_image_filetype() -> Literal["svg", "png"]:
    """If we can convert SVG files, we prefer them over raster images."""
    svg_converter = which("rsvg-convert")
    return "svg" if svg_converter else "png"
