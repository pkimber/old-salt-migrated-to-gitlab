#!/bin/bash
dropbox="{{ account }}"
HOME="/home/web/repo/files/dropbox"
if ! [ -d "$HOME/$dropbox" ]
then
    mkdir "$HOME/$dropbox"
    ln -s "$HOME/.Xauthority" "$HOME/$dropbox/"
fi
HOME="$HOME/$dropbox"
/home/web/.dropbox-dist/dropboxd
