import dataclasses

from tempfile import TemporaryDirectory
from typing import Optional
from urllib.request import urlretrieve
from zipfile import ZipFile

@dataclasses.dataclass
class Package:
    user: str
    repo: Optional[str] = None
    branch: str = "master"

    def download_from_github(self, destination: str):
        """Install a package from GitHub."""
        if self.repo is None:
            self.repo = self.user
        file, _ = urlretrieve(f'https://github.com/{self.user}/{self.repo}/archive/{self.branch}.zip')
        with ZipFile(file, 'r') as archive:
            archive.extractall(destination)
        return destination

    def foo(self):
        tmp = TemporaryDirectory()
        dir = tmp.name

        Package('biopython').download_from_github(dir)
        Package('cython').download_from_github(dir)
        Package('numpy', branch='maintenance/1.22.x').download_from_github(dir)

        find_packages(dir)
