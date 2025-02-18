#!/usr/bin/env bash

# add cargo bin
CARGO_BIN_DIR="$HOME/.local/opt/cargo/bin"
if [[ -d "$CARGO_BIN_DIR" ]]; then
    export PATH="$PATH:$CARGO_BIN_DIR"
fi
