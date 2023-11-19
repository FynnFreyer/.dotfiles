#!/usr/bin/env python

import os

from pathlib import Path
from os.path import expandvars, expanduser

from requests import get


def clean_path(path: str) -> Path:
    return Path(expandvars(expanduser(path))).resolve()  


def find_latest_gh_release_version(org: str, repo: str) -> str:
    api_url = f'https://api.github.com/repos/{org}/{repo}/releases/latest'
    info = get(api_url).json()
    version = info['tag_name'][1:]  # starts with v, so discard first char
    
    return version


def find_latest_gh_dl_url(org: str, repo: str, template: str) -> str:
    version = find_latest_gh_release_version(org, repo)
    template = template.format(version=version)

    return f'https://github.com/{org}/{repo}/releases/download/v{version}/{template}'


def download_file(url: str, dest_path: str):
    dl_path = clean_path(dest_path)
    response = get(url, stream=True)
    with open(dl_path, 'wb') as dl_file:
        for chunk in response.iter_content(chunk_size=128):
            dl_file.write(chunk)


if __name__ == '__main__':
    try:
        dl_url = find_latest_gh_dl_url(
            'obsidianmd',
            'obsidian-releases',
            'Obsidian-{version}.AppImage'
        )
        dest_path = clean_path('~/.local/bin/Obsidian.AppImage')
        download_file(dl_url, dest_path)
        os.chmod(dest_path, 0o755)
    except Exception as e:
        exit('Could not download Obsidian.')
    print(f'Successfully downloaded Obsidian')

