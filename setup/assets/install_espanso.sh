#!/usr/bin/env bash

# install deps
sudo dnf install @development-tools gcc-c++ wl-clipboard libxkbcommon-devel dbus-devel wxGTK-devel
cargo install rust-script --version "0.7.0"
cargo install --force cargo-make --version 0.37.5
export PATH=$PATH:/home/fynn/.cargo/bin

mkdir -p ~/.local/opt
cd ~/.local/opt

# clone
git clone https://github.com/federico-terzi/espanso
cd espanso

# build and install
cargo make --env NO_X11=true --profile release -- build-binary
sudo mv target/release/espanso /usr/local/bin/espanso
sudo setcap "cap_dac_override+p" $(which espanso)
espanso service register
