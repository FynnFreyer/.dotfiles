#!/usr/bin/env bash

shopt -s extglob

if [ -z "$SSH_AUTH_SOCK" ] ; then
  eval $(ssh-agent) > /dev/null
  ssh-add "$HOME/.ssh"/id_!(*.pub)
fi
