#!/usr/bin/env bash

# Source bash completion files
if [ -d ~/.bashrc.d/completions ]; then
    for rc in ~/.bashrc.d/completions/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
