#!/usr/bin/env bash

# Source cargo env if it exists
if [[ -f "$HOME/.cargo/env" ]]; then
  source "$HOME/.cargo/env"
fi

# Add cargo bin dir to PATH
CARGO_BIN_DIR="$HOME/.local/opt/cargo/bin"
if [[ -d "$CARGO_BIN_DIR" ]]; then
    export PATH="$PATH:$CARGO_BIN_DIR"
fi
