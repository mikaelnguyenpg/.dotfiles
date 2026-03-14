#!/usr/bin/env bash
set -e

sudo apt install curl build-essential

# 1. Install Nix (Determinate Systems)
if ! command -v nix &>/dev/null; then
  curl -fsSL https://install.determinate.systems/nix | sh -s -- install
  source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# 2. Clone repo nếu chưa có
DOTFILES="$HOME/.dotfiles"
[ -d "$DOTFILES" ] || git clone https://github.com/you/dotfiles "$DOTFILES"

# 3. Gọi Make
cd "$DOTFILES" && make detect
