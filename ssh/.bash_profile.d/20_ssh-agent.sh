#!/usr/bin/env bash

if [ -z "$SSH_AUTH_SOCK" ] ; then
  eval "$(ssh-agent -s)" > /dev/null
  for key in "$HOME/.ssh"/id_*; do
    # Skip public keys
    [[ $key == *.pub ]] && continue
    
    # Check if key has no password, and if so, add it
    ssh-keygen -y -P "" -f "$key" >/dev/null 2>&1 && ssh-add "$key"
  done
fi
