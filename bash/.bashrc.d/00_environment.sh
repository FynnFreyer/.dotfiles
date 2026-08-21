# explicitly set xdg base dirs
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# these are invented... should probably not prefix them with XDG_
export XDG_BIN_HOME="$HOME/.local/bin"
export XDG_LIB_HOME="$HOME/.local/lib"
export XDG_INCLUDE_HOME="$HOME/.local/include"
export XDG_MAN_HOME="$HOME/.local/man"
export XDG_OPT_HOME="$HOME/.local/opt"


# add user binaries, libs and includes to search PATHs
BIN_DIRS="$XDG_BIN_HOME:$HOME/bin"
LIB_DIRS="$XDG_LIB_HOME"
INCLUDE_DIRS="$XDG_INCLUDE_HOME"

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
