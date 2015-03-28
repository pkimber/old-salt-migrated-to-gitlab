#!/bin/bash

# exit immediately if a command exits with a nonzero exit status.
set -e
# treat unset variables as an error when substituting.
set -u

dropbox="{{ account }}"
HOME="/home/web/repo/files/dropbox"
if ! [ -d "$HOME/$dropbox" ]
then
    mkdir "$HOME/$dropbox"
    ln -s "$HOME/.Xauthority" "$HOME/$dropbox/"
fi
HOME="$HOME/$dropbox"
/home/web/.dropbox-dist/dropboxd
