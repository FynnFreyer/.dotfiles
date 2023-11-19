# Dotfiles

Various files to configure software, and set up my devices.
Configuration packages are roughly organized around the software that's configured, and can be applied with [stow](https://www.gnu.org/software/stow/manual/stow.html).

E.g. to apply my pandoc config you'd do this:

    cd ~
    git clone --recurse-submodules https://github.com/FynnFreyer/.dotfiles
    cd .dotfiles
    stow pandoc

Packages, that I feel are worth a look:

- pandoc
- espanso
- bash
- ssh
- setup (not a stowable config as such)

# Issues

Things that need tweaking/correction

## Setup

Setup script seems to be working okayish.

### Cron

Cron-/Anacrontabs should be set up and kept in sync between machines.
These should be im-/exported via `crontab -u` and `crontab -u < file`.

### Gnome

Config can be dumped and restored via `dconf dump` and `dconf load`.
Also checkout what [the docs](https://help.gnome.org/admin/gdm/stable/configuration.html.en) say about configuration.

This should be part of the automated setup.

- keyboard shortcuts!

