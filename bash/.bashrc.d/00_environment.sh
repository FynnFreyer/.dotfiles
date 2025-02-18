# explicitly set xdg base dirs
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# add user binaries, libs and includes to search PATHs
BIN_DIRS="$HOME/.local/bin:$HOME/bin"
LIB_DIRS="$HOME/.local/lib"
INCLUDE_DIRS="$HOME/.local/include"

if ! [[ "$PATH" =~ $BIN_DIRS ]]; then
    export PATH="$BIN_DIRS:$PATH"
fi

if ! [[ "$LD_LIBRARY_PATH" =~ $LIB_DIRS ]]; then
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$LIB_DIRS"
fi

if ! [[ "$CPATH" =~ $INCLUDE_DIRS ]]; then
    export CPATH="$INCLUDE_DIRS:$CPATH"
fi

LESS_VERSION=$(less -V | grep "less [0-9]" | cut -d" " -f2)
# some flags (e.g., incsearch) are only supported in modern versions
# TODO: find minimum compatible version
if [[ $LESS_VERSION -ge 600 ]]; then
  export LESS="-iKMRSFj5 --incsearch --use-color"  # "--color=Sc --color=Pg --color=Mg --color=Er"
else
  export LESS="-iKMRSFj5 --use-color"
fi

export MANPAGER=less
