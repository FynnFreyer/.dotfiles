#!/bin/sh

cmd=
if type xpip; then
    # prefer xpip over pip
    cmd="xpip install"
    echo pip install xonsh[full] pyyaml requests
elif type pip; then
    # fall back to pip if xpip not available
    cmd="pip install"
else
    # fail if neither xpip or pip are available
    echo "pip not found in $PATH"
    exit 1
fi

if [ -f ~/.config/xonsh/requirements.txt ]; then
    # install requirements
    eval "$cmd -r ~/.config/xonsh/requirements.txt"
else
    # fail if no requirements are found
    # (could alternatively just ignore that, or print warning)
    echo "no requirements found in ~/.config/xonsh/requirements.txt"
    exit 1
fi

# install xonsh
eval "$cmd xonsh[full]"

unset cmd
exit 0
