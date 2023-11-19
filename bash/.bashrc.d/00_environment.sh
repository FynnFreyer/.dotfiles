BIN_DIRS="$HOME/.local/bin:$HOME/bin"

# add user bin dirs to PATH
if ! [[ "$PATH" =~ $BIN_DIRS ]]; then
    export PATH="$BIN_DIRS:$PATH"
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
