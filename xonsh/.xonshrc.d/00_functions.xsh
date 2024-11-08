import sys
import os
import math
import re
import yaml
import json
import requests

from glob import glob
from pathlib import Path
from collections import OrderedDict, defaultdict, namedtuple
from re import match
from importlib import reload, import_module
from csv import reader

def now():
    return $(date '+%F %X').strip()

def time():
    # return $(date '+%R').strip()
    return $(date '+%H:%M:%S').strip()

def term_width() -> int:
    return int($(stty size).strip().split()[1])


def runs_as_root() -> bool:
    return $(whoami).strip() == 'root' and $(id -ur).strip() == '0'


def find_by(f, l) -> int:
    """return the index of the first element in l, fulfilling predicate f, or -1"""
    for i, elem in enumerate(l):
        if f(elem):
            return i
    return -1


def is_graphical_environment() -> bool:
    return 'DISPLAY' in ${...} and $DISPLAY != ''


def load_csv(csv_path: str | Path, sep: str = ',', quote: str = '"', parse: bool = True) -> list[list[str | int | float]]:
    if not Path(csv_path).exists():
        raise FileNotFoundError(f"Can't find path {csv_path}")

    def parse_data(field: str) -> str | int | float:
        if not parse:
            return field

        try:
            return int(field)
        except ValueError:
            ...
        try:
            return float(field)
        except ValueError:
            ...
        return field

    with open(csv_path) as csv_file:
        csv = reader(csv_file, delimiter=sep, quotechar=quote)
        content = [[parse_data(field) for field in row] for row in csv]

    return content
    
def load_tsv(tsv_path: str | Path, quote: str = '"', parse: bool = True) -> list[list[str | int | float]]:
    return load_csv(tsv_path, sep='\t', quote=quote, parse=parse)


def to_script(file_name: str | None = None):
	"""Put the last command into a script file"""
	if file_name is None:
		file_name = "script.xsh"

	last_cmd = $(history show -1)
	script_code = "#!/usr/bin/env xonsh\n\n" + last_cmd
	dest = Path(file_name).resolve()
	if dest.exists():
		print(f"File {dest} exists, aborting.")
	else:
		with dest.open("w") as f:
			f.write(script_code)


def message_in_output(message, process):
    if process.errors:
        return message in process.output or message in process.errors
    else:
        return message in process.output


def raise_on_non_zero_returncode(proc):
    if proc.returncode:
        cmd = ' '.join(proc.args)

        msg = f'Command "{cmd}" failed with returncode {proc.returncode}\n'
        msg += 'No output\n' if not proc.output else f'stdout: \n{proc.output}\n'
        msg += 'No error\n' if not proc.errors else f'stderr: \n{proc.errors}\n'

        raise Exception(msg)


def sync_dotfiles(args, stdin=None):
    work_dir = Path().absolute()
    dotfiles = Path().home() / '.dotfiles'

    if not dotfiles.exists():
        raise Exception(f'.dotfiles directory "{dotfiles}" not found')

    try:
        print('Syncing dotfiles ...')
        os.chdir(dotfiles)
        status = $(git status)
        print(status, '\n')

        print('Committing ...')
        host = $(hostname).strip()
        timestamp = $(date -Imin).strip()
        message = f'{host}@{timestamp}'
        
        commit = !(git commit -am @(message))
        valid_messages = ['Your branch is ahead', 'Your branch is up to date']
        wtf = repr(commit)  # it seems to be necessary to evaluate commit at least once, or it won't properly evaluate the output
        if not any([message_in_output(msg, commit) for msg in valid_messages]):
            raise_on_non_zero_returncode(commit)
        print(commit.output, '\n')

        print('Pulling ...')
        pull = !(git pull)
        raise_on_non_zero_returncode(pull)
        print(pull.output, '\n')

        print('Pushing ...')
        push = ![git push]
        raise_on_non_zero_returncode(push)
        print()

        print('Done!')
    except Exception as e:
        raise e
    finally:
        os.chdir(work_dir)


def xonsh_import(path: str | bytes | os.PathLike | Path = None):
    if path is None:
        path = Path().resolve()
    else:
        path = Path(path).resolve()

    path_content = list(path.iterdir())
    path_names = [path.name for path in path_content]

    # if there is a src sub dir, we want that instead
    if 'src' in path_names:
        src_path = path / 'src'
    else:
        src_path = path

    # only prepend if it's not already there
    if src_path not in sys.path:
        sys.path.insert(0, str(src_path))

    # is there a venv in the root?
    venv_name = 'venv' if 'venv' in path_names else '.venv' if '.venv' in path_names else None
    # venv already active?
    no_venv_set = ${...}.get('VIRTUAL_ENV') is None

    # if we found one, and there's not an active one already
    if venv_name and no_venv_set:
        # relative import, to avoid errors on spaces below
        # could probably escape those, but too much bother
        cwd = os.getcwd()
        os.chdir(path)
        source-bash @(f'{venv_name}/bin/activate')
        os.chdir(cwd)


def notify(message, title = None, device = 'phone'):
    if title is None:
        title = 'Info'

    try:
        device = next(entry.split()[0] for entry in $(gs-connect-cli -a).splitlines() if device in entry)
    except StopIteration:
        raise Exception('Device "{device}" was not found by gs-connect-cli')

    gs-connect-cli --notification=@(title) --notification-body=@(message) --notification-appname=@$(hostname) --device=@(device) --notification-icon=search


def search_wiki(title: str, limit: int = 10, lang = 'en') -> list[tuple[str, str]]:
    """ Search the wikipedia. """
    # cf. https://www.mediawiki.org/wiki/API:Opensearch#Python
    url = 'https://{lang}.wikipedia.org/w/api.php'.format(lang=lang)

    params = {
        'action': 'opensearch',
        'namespace': '0',
        'search': title,
        'limit': limit,
        'format': 'json'
    }

    response = requests.get(url=url, params=params)
    data = response.json()

    return list(zip(data[1], data[3]))

def get_page_content(title: str, lang: str = 'en') -> str:
    url = "https://{lang}.wikipedia.org/w/api.php".format(lang=lang)

    params = {
        'action': 'parse',
        'prop': 'text',
        'page': title,
        'format': 'json'
    }

    response = requests.get(url=url, params=params).json()
    return response['parse']['text']['*']


"""
cf. https://stackoverflow.com/a/7123146
to reload a class after updating it,
when you import like this

import MyPak
from MyPak import MyMod

do

from importlib import reload
del sys.modules['MyPak.MyMod']

reload(MyPak)
from MyPak import MyMod
"""


def xonsh_reload(pkg: str):
    """ Reload a module, and its submodules. Does not reimport its classes. """
    if pkg not in sys.modules:
        print('package not loaded')
        return

    # find sub modules, that need to be thrown out and reloaded after pkg
    needs_reload = [module for module in sys.modules if pkg == module.split('.')[0] and module != pkg]
    # remove them
    for module in needs_reload:
        del sys.modules[module]

    # reload the package
    reload(pkg)

    # reimport submodules
    for module in needs_reload:
        import_module(module)


def clean(string):
    return string.replace('-', '_')


def nmcli_device_info():
    raw_info = $(nmcli device show | grep .).splitlines()
    info_parts = [info.split(':') for info in raw_info]

    list_attrs = set()

    info = defaultdict(dict)
    for parts in info_parts:
        key, value = parts[0].strip(), ':'.join(parts[1:]).strip()

        category, attribute = key.split('.')
        category, attribute = clean(category), clean(attribute)

        is_list = match(r'(.*?)\[(\d+)\]$', attribute)

        if is_list:
            name = clean(is_list[1])
            index = is_list[2]

            list_attrs.add((category, name))

            attributes = info[category].get(name, list())
            attributes.append((index, value))
            info[category][name] = attributes
        else:
            info[category][attribute] = value

    for category, name in list_attrs:
        info[category][name] = tuple([attr for index, attr in sorted(info[category][name])])

    DeviceInfo = namedtuple('DeviceInfo', info.keys())
    for category, attributes in info.items():
        Category = namedtuple(category, attributes.keys())
        info[category] = Category(**attributes)

    return DeviceInfo(**info)
