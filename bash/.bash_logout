# .bashrc
# set -x

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Source global definitions
if [ -f /etc/bash_logout ]; then
    . /etc/bash_logout
fi

# Source user specific environment
if [ -d ~/.bash_logout.d ]; then
    for rc in ~/.bash_logout.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi

unset rc

clear
