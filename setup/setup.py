#!/usr/bin/env python
"""
Set up a fresh Linux install to my liking.

This should support Debian and RHEL based OSs alike.

- Install packages.
- Run setup commands.
- Stow packages.

Specifically it installs all the packages specified in a JSON file, with a structure, similar to the following.

```
root:
    system:
        pkg: list
        apt: list
        dnf: list
    desktop:
        gnome:
            system:
                pkg: list
                apt: list
                dnf: list
            extensions: list
        kde:
            system:SetupPkgSpec
                pkg: list
                apt: list
                dnf: list
            extensions:
                kwinscript: list
                effect: list
                plasmoid: list
    pip: list
```

Then it runs setup commands in another file structured like a normal script file.

```
# comments can only start at the beginning of a line
command1 arg1 arg2
command2 arg1

# including other files via sourcing works
source path/to/other/script

command3 arg1 arg2 arg3
...
```

In the end the dotfile packages indicated by another file are stowed.

```
pkg1
pkg2
...
```

Corresponding classes look like this:

```mermaid
classDiagram:
    class PkgSpec {
        void install()
    }

    PkgSpec <|-- SysPkgSpec
    PkgSpec <|-- PipPkgSpec
    PkgSpec <|-- DesktopPkgSpec
    PkgSpec <|-- ExtensionPkgSpec
    PkgSpec <|-- SetupPkgSpec
    PkgSpec <|-- StowSpec

    DesktopPkgSpec *-- SysPkgSpec
    DesktopPkgSpec *-- ExtensionPkgSpec

    SetupPkgSpec *-- SysPkgSpec
    SetupPkgSpec *-- DesktopPkgSpec
    SetupPkgSpec *-- PipPkgSpec

```

Honestly, I'm stupid for not just using `nix` ...
"""

# TODO
#   - rework pkgs
#   - replace prints with proper logging

from __future__ import annotations

import json
import os
import sys

from abc import ABC, abstractmethod
from argparse import ArgumentParser
from configparser import ConfigParser
from csv import reader as csv_reader
from getpass import getpass, getuser
from json import load as load_json
from os.path import expanduser, expandvars, normpath
from pathlib import Path
from shutil import copyfile, copytree, rmtree, which
from shlex import quote
from string import Template
from subprocess import run
from tarfile import open as taropen
from tempfile import TemporaryDirectory
from typing import Optional, Union, List, Dict, Tuple, Literal
from urllib.request import urlretrieve

# enable fancy messages
ERROR = '\033[30\033[41m'
WARNING = '\033[30\033[43m'
SUCCESS = '\033[30\033[42m'
INFO = '\033[30\033[44m'
RESET = '\033[0m'

ASSET_DIR = Path(__file__).parent / 'assets'


def clean_path(path: Union[str, Path]) -> Path:
    """ Return a normalized and absolute path, with ~ and environment variables expanded. """
    return Path(expanduser(expandvars(normpath(path)))).resolve()


def parse_args(args: Optional[List[str]] = None):
    if args is None:
        args = sys.argv[1:]

    parser = ArgumentParser(
        description='Set up a fresh Linux install to my liking.',
        epilog='Should support Debian and RHEL based OSs alike, if provided with an appropriate packages file.'
    )

    parser.add_argument('-p', '--packages', type=Path, default=ASSET_DIR / 'packages.json',
                        help='JSON file that specifies which packages to install')
    parser.add_argument('-c', '--config', type=Path, default=ASSET_DIR / 'gsettings.conf',
                        help='GNOME key file that specifies dconf options to set')
    parser.add_argument('-s', '--stow', type=Path, default=ASSET_DIR / 'stow.json',
                        help='JSON file containing a list of packages to stow')
    parser.add_argument('-i', '--ide', type=Path, default=ASSET_DIR / 'ides.json',
                        help='JSON file containing a list of IDEs to install')

    parser.add_argument('-v', '--verbose', action='store_true', help='more verbose output')

    return parser.parse_args(args)


class PkgSpec(ABC):
    """ Abstract base class for package install specifications. """

    @abstractmethod
    def install(self, verbose: bool = False) -> None:
        raise NotImplemented

    def _proc_conf(self, verbose: bool = False):
        return {
            'check': True,
            'text': True,
            'stdout': sys.stdout if verbose else None,
            'stderr': sys.stderr if verbose else None,
        }


class SysPkgSpec(PkgSpec):
    """ Describes a set of packages to be installed from the system repositories. """

    pkgs: Tuple[str]

    def __init__(self, mapping: Dict[str, List[str]]):
        pkgs = mapping.get('pkg', [])

        assert self.is_rhel() or self.is_debian(), 'Neither apt, nor dnf found in $PATH'

        if self.is_debian():
            pkgs.extend(mapping.get('apt', []))
        elif self.is_rhel():
            pkgs.extend(mapping.get('dnf', []))

        self.pkgs = tuple(pkgs)

    def install(self, verbose: bool = False) -> None:
        """ Install the requested packages with the appropriate package manager. """
        if self.pkgs:
            pkg_mngr = 'apt' if self.is_debian() else 'dnf' if self.is_rhel() else None
            assert pkg_mngr, 'No valid package manager found'
            os.system(" ".join(['sudo', '-S', pkg_mngr, 'install', '-y', *self.pkgs]))

    def is_rhel(self) -> bool:
        """ Find out whether this distro is RHEL based, by checking if `dnf` is available. """
        return which('dnf') is not None

    def is_debian(self) -> bool:
        """ Find out whether this distro is Debian based, by checking if `apt` is available. """
        return which('apt') is not None


class PipPkgSpec(PkgSpec):
    """ Describes a set of packages to be installed via `pip`. """

    pkgs: Tuple[str]

    def __init__(self, pkgs: List[str]):
        self.pkgs = tuple(pkgs)

    def install(self, verbose: bool = False) -> None:
        """ Install packages via `pip`. """
        assert getuser() != 'root', 'Installing pip packages as root is not supported'

        if self.pkgs:
            run([sys.executable, '-m', 'pip', 'install', 'wheel', 'setuptools'], **self._proc_conf(verbose))
            pkg_proc = run([sys.executable, '-m', 'pip', 'install', *self.pkgs], **self._proc_conf(verbose))


def get_desktop_environments() -> List[str]:
    """ Return list of desktop environments in use. """
    return os.getenv('XDG_CURRENT_DESKTOP', '').split(':')


def is_kde() -> bool:
    """ Is KDE used? Not necessarily mutually exclusive with `is_gnome`! """
    return 'KDE' in get_desktop_environments()


def is_gnome() -> bool:
    """ Is GNOME used? Not necessarily mutually exclusive with `is_kde`! """
    return 'GNOME' in get_desktop_environments()


class DesktopPkgSpec(PkgSpec):
    """ Describes sets of packages and extensions that are dependent on a particular desktop environment. """

    gnome_sys_pkgs: SysPkgSpec
    gnome_exts: Tuple[str]

    kde_sys_pkgs: SysPkgSpec
    kde_exts: Tuple[Tuple[str, Tuple[str, ...]]]

    def __init__(self, mapping: Dict[str, Dict[str, List[str]]]):
        # GNOME and KDE are not mutually exclusive!
        if is_gnome():
            gnome = mapping.get('gnome', {})
            self.gnome_sys_pkgs = SysPkgSpec(gnome)
            self.gnome_exts = tuple(gnome.get('extensions', []))
        else:
            self.gnome_sys_pkgs = None

        if is_kde():
            kde = mapping.get('kde', {})
            self.kde_sys_pkgs = SysPkgSpec(kde)
            self.kde_exts = tuple(
                (ext_type, tuple(url_list))
                for ext_type, url_list
                in kde.get('extensions', {}).items()
            )
        else:
            self.kde_sys_pkgs = None

    def install(self, verbose: bool = False) -> None:
        """ Install the DE specific system packages and the DE extensions. """
        dl_dst = os.getenv('XDG_DOWNLOAD_DIR', os.getenv('HOME') + '/Downloads')
        dl_dir = clean_path(dl_dst)

        self._install_gnome(dl_dir, verbose)
        self._install_kde(dl_dir, verbose)

    def _install_kde(self, dl_dir: Path, verbose: bool = False) -> None:
        """ Install KDE specific programs and extensions. """
        if self.kde_sys_pkgs is not None:
            self.kde_sys_pkgs.install(verbose)

            # For installing KDE extensions, I have to download the tar balls,
            # and then use `plasmapkg2` or `kpackagetool5` with the `--install` flag.
            # It's important to set the appropriate `--type` argument.
            if self.kde_exts:
                for ext_type, ext_urls in self.kde_exts:
                    for ext_url in ext_urls:
                        out_doc = dl_dir / 'ext.tar.gz'
                        ext_dir = dl_dir / 'ext'
                        ext_dir.mkdir()

                        dl_proc = run(['wget', f'--output-document={out_doc}', ext_url], **self._proc_conf(verbose))
                        untar_proc = run(['tar', f'--one-top-level={ext_dir}', '-xzvf', str(out_doc)],
                                         **self._proc_conf(verbose))

                        try:
                            inst_proc = run([
                                'kpackagetool5',
                                '--type', ext_type,
                                '--install', str(next(ext_dir.glob('**/metadata.desktop')).parent)
                            ],
                                **self._proc_conf(verbose)
                            )
                        except Exception as e:
                            raise e
                        finally:
                            out_doc.unlink()
                            rmtree(ext_dir)

    def _install_gnome(self, dl_dir: Path, verbose: bool = False) -> None:
        """ Install GNOME specific programs and extensions. """
        if self.gnome_sys_pkgs is not None:
            self.gnome_sys_pkgs.install(verbose)

            # For installing GNOME extensions, I have to download the zip archives,
            # and then use `gnome-extensions-app install`.
            # make sure gnome-extensions-app is in $PATH
            exts_in_path = not os.system('gnome-extensions version > /dev/null')
            assert exts_in_path, 'Could not find gnome-extensions in $PATH'

            if self.gnome_exts:
                for ext_url in self.gnome_exts:
                    out_doc = dl_dir / 'ext.zip'
                    try:
                        dl_proc = run(['wget', f'--output-document={out_doc}', ext_url], **self._proc_conf(verbose))
                        inst_proc = run(['gnome-extensions', 'install', '--force', str(out_doc)],
                                        **self._proc_conf(verbose))
                    except Exception as e:
                        raise e
                    finally:
                        out_doc.unlink()


class SetupPkgSpec(PkgSpec):
    """
    Describes the complete setup.
    """

    sys_pkgs: SysPkgSpec
    de_pkgs: DesktopPkgSpec
    pip_pkgs: PipPkgSpec

    def __init__(self, path: Path):
        print(f'{INFO}INFO: installing software.{RESET}')
        with path.open() as json:
            mapping = load_json(json)

        self.sys_pkgs = SysPkgSpec(mapping.get('system', {}))
        self.de_pkgs = DesktopPkgSpec(mapping.get('desktop', {}))
        self.pip_pkgs = PipPkgSpec(mapping.get('pip', {}))

    def install(self, verbose: bool = False) -> None:
        self.sys_pkgs.install(verbose)
        self.de_pkgs.install(verbose)
        self.pip_pkgs.install(verbose)


def get_os_release() -> Dict[str, str]:
    """
    Return a dict representing the contents of `/etc/os-release`. Checking for OS is actually done via
    `shutil.which(pkg_mngr)` though.

    Shout out to Hai Vu for the clean solution. Cf. https://dev.to/htv2012/how-to-parse-etc-os-release-3kaj
    """
    with open('/etc/os-release') as release:
        return dict(csv_reader(release, delimiter='='))


class PathManager:
    def __init__(self, path):
        self.path = clean_path(path)
        self.cwd = os.getcwd()
        self._actual_change = str(self.path) != self.cwd

    def __enter__(self) -> Path:
        if self._actual_change:
            print(f'{INFO}INFO: switching path to {self.path}.{RESET}')
            os.chdir(self.path)
        return self.path

    def __exit__(self, exc_type, exc_value, exc_tb):
        if self._actual_change:
            print(f'{INFO}INFO: restoring original path {self.cwd}.{RESET}')
        os.chdir(self.cwd)


class RepoRootManager(PathManager):
    def __init__(self, cwd: bool = False):
        """
        :param cwd: Whether to find the repo relative to the current working directory or ``__file__``.
        """
        path = Path(__file__).parent
        if cwd:
            path = Path(os.getcwd())
        with PathManager(path):
            repo_root = run(
                ['git', 'rev-parse', '--show-toplevel'],
                capture_output=True,
                text=True,
                check=True
            ).stdout[:-1]

        super().__init__(repo_root)


def git_lfs_pull() -> None:
    """Make sure git-lfs is installed and pull files."""
    print(f'{INFO}INFO: making sure git-lfs is installed{RESET}')
    assert not os.system('git lfs version > /dev/null'), 'Could not find git lfs'

    with RepoRootManager():
        print(f'{INFO}INFO: pull LFS files{RESET}')
        run(['git', 'lfs', 'pull'], check=True)


def git_update_submodules() -> None:
    """Initialize and update git submodules."""
    with RepoRootManager():
        print(f"{INFO}INFO: Initializing git submodules.{RESET}")
        run(['git', 'submodule', 'update', '--init', '--recursive'], check=True)


def git_set_origin(url: str = 'git@github.com:FynnFreyer/.dotfiles') -> None:
    """Enable SSH authentication by setting the origin."""
    with RepoRootManager():
        run(['git', 'remote', 'set-url', 'origin', url], check=True)


def git_setup() -> None:
    """Make sure the ``.dotfiles`` repo is properly setup."""
    git_update_submodules()
    git_lfs_pull()
    git_set_origin()


def install_keepass_attachments(db: Union[str, Path], attachments: Tuple[Tuple[str, str, Union[str, Path]], ...]):
    """
    Installs attachments from a KeePassXC database into the file system.

    :param db: Path to the database
    :param attachments: Tuple of (attachment_path, attachment_name, attachment_destination).
    """
    print(f"{INFO}INFO: Installing SSH keys.{RESET}")
    db = quote(str(clean_path(db)))

    with PathManager(Path.home()):
        while True:
            password = quote(getpass(f'Need access to KeePassXC database {db} to export attachments.\n'
                                     f'Please provide the password: '))
            if os.system(f'echo {password} | keepassxc-cli ls {db} 2>&1 > /dev/null') != 0:
                print(f'{WARNING}Incorrect password, please try again.{RESET}')
            else:
                break

        for attachment_path, attachment_name, attachment_destination in attachments:
            dst = clean_path(attachment_destination)
            if dst.is_dir():
                dst /= attachment_name

            run(['keepassxc-cli', 'attachment-export', str(db), attachment_path, attachment_name, str(dst)],
                input=password + '\n', text=True, check=True)

        del password


def secure_and_add_ssh_keys():
    """
    Set permission, and password on, and add to ssh-agent, all files in `~/.ssh`, starting with `id_` and not ending in
    `.pub`.
    """
    print(f"{INFO}INFO: Securing SSH keys and adding them to the SSH-agent.{RESET}")
    keys = [str(file) for file in clean_path('~/.ssh').glob('id_*') if file.is_file() and not file.suffix == '.pub']

    if keys:
        # while True:
        #     password = getpass(f'Please provide password to lock ssh keys: ')
        #     confirmation = getpass(f'Please confirm password: ')

        #     if password == confirmation:
        #         break

        #     print(f"{WARNING}Passwords don't match, please try again...{RESET}")

        for key in keys:
            run(['chmod', '600', key], check=True)
            # TODO mucks up passwords somehow
            # run(['ssh-keygen', '-p', '-N', password, '-f', key], check=True)

        run(['ssh-add', *keys])


class StowPkgSpec(PkgSpec):
    package_directory: Path
    target_directory: Path

    def __init__(self, package_directory: Union[str, Path], target_directory: Union[str, Path]):
        self.package_directory = clean_path(package_directory)
        self.target_directory = clean_path(target_directory)

    def install(self, verbose: bool = False):
        # make sure stow is in $PATH
        assert not os.system('stow -V > /dev/null'), 'Could not find stow in $PATH'
        self._prepare_stow()
        with PathManager(self.package_directory.parent):
            run([
                'stow',
                '--no-folding',
                '--dotfiles',
                '--target', str(self.target_directory),
                str(self.package_directory.name)
            ], check=True)

    def _prepare_stow(self):
        """
        If a file `target`, relative to `package_directory`, also exists relative to `target_directory`, unlink the
        `target` in `target_directory`. Don't do anything on links, or if the target resides in a linked directory
        (i.e. `target != target.resolve()`).
        """
        for (dirpath, dirnames, filenames) in os.walk(self.package_directory):
            for name in filenames:
                current = Path(dirpath) / name
                relative = current.relative_to(self.package_directory)
                target = self.target_directory / relative
                # is_file is unnecessary, because we iterate over filenames already, but look at it as a sanity check
                # (e.g. in case we change what we iterate over)
                if target.exists() and target.is_file() and not target.is_symlink() and target == target.resolve():
                    print(f'{WARNING}Unlinking {target}.{RESET}')
                    target.unlink()


def install_mozilla_config():
    """Install configuration files for Firefox and Thunderbird."""
    install_tb_config()
    install_ff_config()


def install_tb_config():
    """Install configuration files for Thunderbird."""
    print(f'{INFO}INFO: installing Thunderbird config.{RESET}')
    tb_policies = ASSET_DIR / 'thunderbird/policies.json'
    policy_target = Path('/etc/thunderbird/policies')

    # we're working in system directories -> this needs root
    os.system(f'sudo mkdir -p {policy_target}')
    os.system(f'sudo cp "{tb_policies}" "{policy_target / "policies.json"}"')


def install_ff_config():
    """Install configuration files for Firefox."""
    print(f'{INFO}INFO: installing Firefox config.{RESET}')

    # find userChrome.js loader
    setup_ff_program_dir()
    profile_name = setup_ff_profile_dir()

    # delete startup cache
    cache_path = clean_path('~/.cache/mozilla/firefox') / profile_name / 'startupCache'
    rmtree(cache_path, ignore_errors=True)
    cache_path.mkdir(parents=True)


def setup_ff_program_dir():
    """Install ``userChrome.js`` loader files to the installation directory."""
    autoconf_dir = ASSET_DIR / 'firefox/autoconfig'
    for dir in ['lib', 'lib64']:
        program_path = clean_path(f'/usr/{dir}/firefox/')
        bin_path = program_path / 'firefox'
        if bin_path.is_file():
            break
    else:
        # TODO error message program install folder not found
        raise RuntimeError

    ff_config_js = autoconf_dir / 'config.js'
    ff_defaults = autoconf_dir / 'defaults'

    # we're working in system directories -> this needs root
    os.system(f'sudo cp -r "{ff_defaults}" "{program_path}"')
    os.system(f'sudo cp "{ff_config_js}" "{program_path}"')


def setup_ff_profile_dir():
    """Install ``userChrome.css`` and userscripts to the profile folder."""
    with clean_path('~/.mozilla/firefox/profiles.ini').open() as profiles_file:
        config = ConfigParser()
        config.read_file(profiles_file)

    for section in config.sections():
        opts = dict(config[section])
        if opts.get('name') == 'default-release':
            profile_name = opts['path']
            profile_path = clean_path('~/.mozilla/firefox') / profile_name
            break
    else:
        # TODO error message profile folder not found
        raise RuntimeError

    # symlink user prefs
    userJS_src = ASSET_DIR / 'firefox/profile/user.js'
    userJS_dest = profile_path / 'user.js'
    userJS_dest.unlink(missing_ok=True)
    userJS_dest.symlink_to(userJS_src)

    # create chrome directory
    chrome_dest = profile_path / 'chrome'
    chrome_dest.mkdir(exist_ok=True)

    # symlink user chrome
    chrome_src = ASSET_DIR / 'firefox/profile/chrome'
    StowPkgSpec(chrome_src, chrome_dest).install(verbose=True)

    return profile_name


# TODO move to file in assets directory
_desktop_file_template = Template("""#!/usr/bin/env xdg-open

[Desktop Entry]
Version=1.0

Type=Application

Name=${long_name}
MimeType=${mime_types}
Categories=TextEditor;Development;IDE;Debugger;${categories}
Comment=Start ${long_name}
Keywords=Programming;JetBrains

Exec=${home}/.local/bin/${name}
Icon=${home}/.local/share/icons/${name}.svg
Terminal=false

StartupWMClass=${name}
StartupNotify=true
""")


def install_ide(name: str,
                long_name: str | None = None,
                url: str | None = None,
                ide_home: str | None = None,
                overwrite: bool = False,
                mime_types: list[str] | None = None,
                categories: list[str] | None = None,
                desktop_file_template: Template = _desktop_file_template):
    """
    Install a JetBrains IDE. Can take a URL to a tar archive.

    :param name: The short name used in the archive, e.g., "idea". I could probably find it programatically, but I'm lazy.
    :param long_name: Canonical name of the IDE, e.g., "IntelliJ IDEA". Defaults to the capitalized name if not set.
    :param url: A link to the tar archive to install. Assumed to be downloaded already if not provided.
    :param overwrite: Whether data in ide_home should be overwritten if url was passed. Defaults to False.
    :param ide_home: Where the IDE files are (or where to put them if url is passed). Defaults to f"~/.local/opt/jetbrains/{name}". IDE is then installed by symlinking to "~/.local/bin".
    :param mime_types: Optionally a list of mimetypes to associate the IDE with. E.g. "text/html"
    :param categories: Optionally a list of registered freedesktop.org categories to associate the IDE with. E.g. "WebDevelopment".
    :param desktop_file_template: A template for the .desktop file. Can use the other parameters as variables.
    :raise FileNotFoundError: If no url was passed and ide_home doesn't exist.
    """

    home = Path.home()
    ide_home = ide_home if ide_home is not None else home / f'.local/opt/jetbrains/{name}'
    long_name = long_name if long_name is not None else name.capitalize()
    mime_types = mime_types if mime_types is not None else []
    categories = categories if categories is not None else []

    print(f'{INFO}INFO: installing IDE {long_name}.{RESET}')

    if url and (not ide_home.exists() or overwrite):
        # ensure clean state
        if ide_home.exists():
            rmtree(ide_home)
        ide_home.mkdir(parents=True)

        # download and unpack tar archive
        with TemporaryDirectory() as tmp:
            tmp_dir = Path(tmp)
            tmp_dl = tmp_dir / 'file.tar.gz'
            urlretrieve(url, tmp_dl)

            # copy archive content to ide_home
            with taropen(tmp_dl, 'r:gz') as tarfile:
                # the archive contains a top level folder that we need to find
                folder = tmp_dir / tarfile.next().name.split('/')[0]
                tarfile.extractall(tmp_dir, filter='data')
                copytree(folder, ide_home, dirs_exist_ok=True)

    elif url and ide_home.exists() and not overwrite:
        print(f'{WARNING}WARNING: passed a URL without specifying overwrite, but "{ide_home}" exists: '
              f'skipping download.{RESET}')

    elif not url and not ide_home.exists():
        print(f'{ERROR}ERROR: "{ide_home}" does not exist, but no url was passed. Aborting.{RESET}')
        raise FileNotFoundError(f'ERROR: "{ide_home}" does not exist, but no url was passed. Aborting.')

    # install, by linking to ~/.local/bin/
    run(['ln', '-srf', str(ide_home / f'bin/{name}'), str(home / '.local/bin/')], check=True)
    run(['ln', '-srf', str(ide_home / f'bin/{name}.svg'), str(home / '.local/share/icons/')], check=True)

    category_string = ';'.join(categories)
    mime_type_string = ';'.join(mime_types)

    content = desktop_file_template.substitute(
        name=name,
        long_name=long_name,
        mime_types=mime_type_string,
        categories=category_string,
        home=Path.home(),
    )

    desktop_file_path = Path.home() / f'.local/share/applications/{name}.desktop'

    with open(desktop_file_path, 'w') as desktop_file:
        desktop_file.write(content)


def main(args):
    """ Install everything. """
    setup_spec = SetupPkgSpec(args.packages)
    # setup_spec.install(args.verbose)

    print(f'{INFO}INFO: setting up git remote.{RESET}')
    git_setup()

    print(f'{INFO}INFO: stowing packages.{RESET}')
    stow_pkg_path = args.stow
    with stow_pkg_path.open() as stow_pkg_file, RepoRootManager():
        pkgs = json.load(stow_pkg_file)
        for pkg in pkgs:
            StowPkgSpec(pkg, '~') #.install()

    ssh_dir = clean_path('~/.ssh/')
    ssh_dir.mkdir(exist_ok=True)

    attachments = (
        ('Privat/Tech/Server/Server - Bydlo', 'id_bydlo', ssh_dir),
        ('Privat/Tech/Server/Server - Schmuyle', 'id_schmuyle', ssh_dir),
        ('Privat/Tech/Home/Router - OpenWRT', 'id_openwrt', ssh_dir),
        ('Privat/Tech/GitHub', 'id_github', ssh_dir),
        ('Arbeit/Wojtek/Azure', 'id_azure', ssh_dir),
        ('Arbeit/Wojtek/HTW', 'id_htw_rsa', ssh_dir),
    )

    #install_keepass_attachments('~/pw.kdbx', attachments)
    #secure_and_add_ssh_keys()

    # # install IDEs
    ide_data_path = args.ide
    with ide_data_path.open() as ide_data_file:
        # url pattern: https://download-cdn.jetbrains.com/{lang_code}/{ide_name}-{version}.tar.gz
        data = json.load(ide_data_file)
        for ide in data:
            install_ide(**ide, overwrite=False)

    install_mozilla_config()

    print(f'{INFO}INFO: installing dconf settings.{RESET}')
    with args.config.open() as conf_file:
        config = conf_file.read()
    run(['dconf', 'load', '-f', '/'], text=True, check=True, input=config)

    print(f'{INFO}INFO: installing espanso.{RESET}')
    espanso_installer = ASSET_DIR / 'install_espanso.sh'
    #run(['bash', str(espanso_installer)], check=True)


if __name__ == '__main__':
    try:
        args = parse_args()
        main(args)
    except KeyboardInterrupt:
        print(f'\n\n{INFO}User aborted installation. Bye Bye!{RESET}')
        exit(0)
    except Exception as error:
        print(f'{ERROR}ERROR:\n{error.__class__}: {error}{RESET}\n\n')
        print(f'{ERROR}An error occured. Aborting ...{RESET}')
        exit(1)
    else:
        print(f'{INFO}Setup complete. Please reboot at your earliest convenience.{RESET}')
