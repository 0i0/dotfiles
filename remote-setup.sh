#!/usr/bin/env bash

CMD="curl -#L"
if [ -z "$CMD" ]; then
  echo "No curl or wget available. Aborting."
else
  echo "Installing dotfiles-server"
  mkdir -p "$HOME/dotfiles-server" && \
  eval "$CMD https://github.com/0i0/dotfiles/tarball/master | tar -xzv -C ~/dotfiles --strip-components=1 --exclude='{.gitignore}'"
  . "$HOME/dotfiles-server/setup.sh"
fi