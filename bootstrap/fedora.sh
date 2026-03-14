#!/usr/bin/env bash
set -e

sudo dnf install -y curl git wget unzip gcc gcc-c++ make ca-certificates gnupg2 redhat-lsb-core

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
