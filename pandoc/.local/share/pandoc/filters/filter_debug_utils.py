"""
Debug utilities for pandoc filters.
"""

from __future__ import annotations

import os
import sys

from json import loads, dumps, JSONDecodeError
from pathlib import Path
from subprocess import run
from typing import Callable, Optional, Any

from pandocfilters import applyJSONFilters, toJSONFilter


def try_load(value: str) -> dict | list | float | int | str:
    """
    Try to load a value as JSON, float or int, and fall back to str if that
    fails.

    :param value: A string, that may be JSON formatted, or represent a float, int or string.
    :return: A dict, list, float, int or string, parsed from the input value.
    """
    try:
        return loads(value)
    except JSONDecodeError:
        pass
    try:
        return float(value)
    except ValueError:
        pass
    try:
        return int(value)
    except ValueError:
        pass
    return value


def format_arg(arg: Optional[str | dict], arg_name: str = "") -> str:
    """
    String format information on a filter argument.

    :param arg: An argument to a filter function.
    :param arg_name: The name of the function parameter.
    :return: A string representation.
    """
    arg_type = type(arg).__name__
    arg_info = f"{arg_name} ({arg_type})" if arg_name else arg_type
    return f"{arg_info}: {dumps(arg, indent=2)}"


def dbg_decorator(action: Callable[[str, str, str, Optional[dict]], Optional[dict]]) \
        -> Callable[[str, str, str, Optional[dict]], Optional[dict | Any]]:
    """
    Wrap a filter function, so it outputs more debug information.

    :param action: A filter function to wrap.
    :return: The wrapped function.
    """

    def wrapper(key: str, value: str, format: str, meta: Optional[dict]) -> Optional[dict | Any]:
        env_data = dumps({
            key: try_load(value)
            for key, value
            in os.environ.items()
            if key.upper().startswith('PANDOC')
        }, indent=2)

        arg_data = "\n".join([
            format_arg(key, "key"),
            format_arg(value, "value"),
            format_arg(format, "format"),
            format_arg(meta, "meta"),
        ])

        sys.stderr.write(f"Pandoc data:\n{env_data}\n\n"
                         f"Filter args:\n{arg_data}\n\n")

        return action(key, value, format, meta)

    return wrapper


def run_dbg_filter(action: Callable[[str, str, str, Optional[dict]], Optional[dict | Any]],
                   file: str | bytes | os.PathLike) -> str:
    """
    Run a filter on a file. Not more verbose, because you can just check things
    in the debugger instead.

    :param action: The filter action to run.
    :param file: The file to use the filter on.
    :return: The resulting HTML.
    """
    file = str(Path(file).resolve())
    proc = run(['pandoc', '-t', 'json', '-s', file], check=True, text=True, capture_output=True)
    json_source = proc.stdout
    output = applyJSONFilters([action], json_source)
    return output


def create_dbg_filter(action: Callable[[str, str, str, Optional[dict]], Optional[dict | Any]]) -> None:
    """
    Create a more verbose filter.
    
    :param action: The filter action.
    :return: Nothing.
    """
    return toJSONFilter(dbg_decorator(action))
