#!/usr/bin/env xonsh

import sys
from json import loads as json_load
from yaml import safe_load as yaml_load


def find_latest_release():
    api_url = 'https://api.github.com/repos/ramboxapp/download/releases/latest'
    browser_url = 'https://github.com/ramboxapp/download/releases'
    info = json_load($(curl @(api_url) 2> /dev/null))

    try:
        latest = next(filter(lambda asset: asset['name'] == 'latest-linux.yml', info['assets']))
    except StopIteration:
        raise Exception(f'Could not find information on latest release, '
                        f'please install manually from {browser_url}/latest')

    dl_url_template = 'download/v{version}/Rambox-{version}-linux-x64.AppImage'

    latest_info = yaml_load($(curl -L @(latest['browser_download_url']) 2> /dev/null))
    version = latest_info['version']
    return {'version': version, 'url': f'{browser_url}/{dl_url_template.format(version=version)}'}


if __name__ == '__main__':
    try:
        pushd ~/.local/bin
        release_info = find_latest_release()
        curl -L @(release_info['url']) -o RamboxNew.AppImage  # 2> /dev/null
        mv RamboxNew.AppImage Rambox.AppImage
        chmod u+x Rambox.AppImage
    except Exception as e:
        print(e.args[0])
        sys.exit('Could not download rambox.')
    finally:
        popd
    print(f'Successfully downloaded rambox v{release_info["version"]}')
