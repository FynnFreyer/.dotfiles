BIN_DIRS="$HOME/.local/bin:$HOME/bin"
LIB_DIRS="$HOME/.local/lib"
INCLUDE_DIRS="$HOME/.local/include"

# add user binaries, libs and includes to search PATHs
if ! [[ "$PATH" =~ $BIN_DIRS ]]; then
    export PATH="$BIN_DIRS:$PATH"
fi

if ! [[ "$LD_LIBRARY_PATH" =~ $LIB_DIRS ]]; then
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$LIB_DIRS"
fi

if ! [[ "$CPATH" =~ $INCLUDE_DIRS ]]; then
    export CPATH="$INCLUDE_DIRS:$CPATH"
fi

# add cargo bin
if [[ -d "$HOME/.cargo/bin" ]]; then
    export PATH="$PATH:$HOME/.cargo/bin"
fi

# set lv2-plugin search path for ardour
export LV2_PATH=/home/fynn/Documents/Projekte/Ardour/Ardour_Plugins/

LESS_VERSION=$(less -V | grep "less [0-9]" | cut -d" " -f2)
# some flags (e.g., incsearch) are only supported in modern versions
# TODO: find minimum compatible version
if [[ $LESS_VERSION -ge 600 ]]; then
  export LESS="-iKMRSFj5 --incsearch --use-color"  # "--color=Sc --color=Pg --color=Mg --color=Er"
else
  export LESS="-iKMRSFj5 --use-color"
fi

export MANPAGER=less
